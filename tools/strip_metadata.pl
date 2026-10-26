#!/usr/bin/perl
# 画像のメタデータ（位置情報・撮影日時・機種名など）を確認・削除する
# 使い方: perl tools/strip_metadata.pl report|strip ファイル...
#   report: 見つかったメタデータを表示するだけ / strip: 削除して上書き保存
# JPEG: Exif・XMP・IPTC・コメント・画像末尾の追加データを削除（JFIF・ICC カラープロファイル・Adobe APP14 は残す）
#       回転情報(Orientation)が 1 以外なら、向きが崩れないよう Orientation だけ書き戻す
# PNG:  eXIf・tEXt・zTXt・iTXt・tIME チャンクを削除
use strict; use warnings;
my $mode = shift @ARGV;

sub rd { my $f = shift; open my $h, '<:raw', $f or die "$f: $!"; local $/; my $d = <$h>; close $h; $d }
sub wr { my ($f, $d) = @_; open my $h, '>:raw', $f or die "$f: $!"; print $h $d; close $h }

sub parse_exif {    # returns hash of interesting tags from TIFF data
    my $t = shift; my %r;
    my $le = substr($t, 0, 2) eq 'II';
    my $u16 = sub { my $o = shift; return undef if $o + 2 > length $t; unpack($le ? 'v' : 'n', substr($t, $o, 2)) };
    my $u32 = sub { my $o = shift; return undef if $o + 4 > length $t; unpack($le ? 'V' : 'N', substr($t, $o, 4)) };
    my %names = (0x010F => 'Make', 0x0110 => 'Model', 0x0131 => 'Software', 0x0132 => 'DateTime',
        0x9003 => 'DateTimeOriginal', 0x9004 => 'DateTimeDigitized', 0x013B => 'Artist', 0x8298 => 'Copyright',
        0xA434 => 'LensModel', 0xA431 => 'SerialNumber', 0x0112 => 'Orientation');
    my $walk; $walk = sub {
        my ($off, $ifd, $seen) = @_;
        return if !defined $off || $off == 0 || $seen->{$off}++;
        my $n = $u16->($off) // return;
        for my $i (0 .. $n - 1) {
            my $e = $off + 2 + 12 * $i;
            my ($tag, $type, $cnt) = ($u16->($e), $u16->($e + 2), $u32->($e + 4));
            last unless defined $cnt;
            if ($tag == 0x8769) { $walk->($u32->($e + 8), 'exif', $seen); next }
            if ($tag == 0x8825) { $r{GPS} = 'present'; $walk->($u32->($e + 8), 'gps', $seen); next }
            if ($ifd eq 'gps') { $r{GPS} = 'present (with coordinates)' if $tag == 2 || $tag == 4; next }
            next unless $names{$tag};
            if ($type == 2) {
                my $v = $cnt <= 4 ? substr($t, $e + 8, $cnt) : substr($t, $u32->($e + 8) // 0, $cnt);
                $v =~ s/\0.*//s; $r{$names{$tag}} = $v;
            } elsif ($type == 3) { $r{$names{$tag}} = $u16->($e + 8) }
        }
    };
    $walk->($u32->(4), 'ifd0', {});
    return \%r;
}

sub min_exif_orientation {
    my $o = shift;
    my $tiff = "MM\0\x2a" . pack('N', 8) . pack('n', 1) . pack('nnNnn', 0x0112, 3, 1, $o, 0) . pack('N', 0);
    my $p = "Exif\0\0" . $tiff;
    return "\xFF\xE1" . pack('n', length($p) + 2) . $p;
}

sub do_jpeg {
    my ($f, $d) = @_;
    my (@found, $out, $orient);
    $out = substr($d, 0, 2); my $p = 2;
    while ($p < length $d) {
        my $m = ord substr($d, $p + 1, 1);
        if ($m == 0xDA) {    # start of scan: copy through EOI
            my $eoi = index($d, "\xFF\xD9", $p);
            $eoi = length($d) - 2 if $eoi < 0;
            my $tail = length($d) - ($eoi + 2);
            push @found, "trailing data after image: $tail bytes" . ($d =~ /Exif\0\0/ && index($d, "Exif\0\0", $eoi) >= 0 ? ' (contains Exif)' : '') if $tail > 0;
            $out .= substr($d, $p, $eoi + 2 - $p);
            last;
        }
        my $len = unpack 'n', substr($d, $p + 2, 2);
        my $seg = substr($d, $p, $len + 2);
        my $payload = substr($seg, 4);
        my $drop = 0;
        if ($m == 0xE1 && $payload =~ /^Exif\0\0/) {
            my $r = parse_exif(substr($payload, 6));
            $orient = $r->{Orientation};
            if ($orient && $seg eq min_exif_orientation($orient)) { $out .= $seg; $orient = undef; $p += $len + 2; next }    # 処理済み（回転情報のみ）
            push @found, 'Exif: ' . join(', ', map { "$_=$r->{$_}" } sort keys %$r);
            $drop = 1;
        } elsif ($m == 0xE1) { push @found, 'XMP' . ($payload =~ /GPS/ ? ' (contains GPS)' : '') . ($payload =~ /CreateDate|DateCreated/ ? ' (contains dates)' : ''); $drop = 1 }
        elsif ($m == 0xE2 && $payload !~ /^ICC_PROFILE/) { push @found, 'APP2 ' . substr($payload, 0, 4); $drop = 1 }
        elsif (($m >= 0xE3 && $m <= 0xED) || $m == 0xEF) { push @found, sprintf('APP%d', $m - 0xE0); $drop = 1 }
        elsif ($m == 0xFE) { push @found, 'Comment: ' . substr($payload, 0, 60); $drop = 1 }
        $out .= $seg unless $drop;
        $p += $len + 2;
    }
    if ($orient && $orient != 1) {    # keep only rotation so the photo isn't displayed sideways
        my $ins = substr($out, 2, 2) eq "\xFF\xE0" ? 4 + unpack('n', substr($out, 4, 2)) : 2;
        substr($out, $ins, 0) = min_exif_orientation($orient);
    }
    return (\@found, $out);
}

sub do_png {
    my ($f, $d) = @_;
    my (@found, $out); $out = substr($d, 0, 8); my $p = 8;
    while ($p + 8 <= length $d) {
        my ($len, $type) = unpack 'Na4', substr($d, $p, 8);
        my $chunk = substr($d, $p, $len + 12);
        if ($type =~ /^(eXIf|tEXt|zTXt|iTXt|tIME)$/) {
            my $info = $type eq 'tEXt' ? ': ' . substr(substr($chunk, 8, $len), 0, 60) : '';
            $info =~ s/\0/=/; push @found, "$type$info";
        } else { $out .= $chunk }
        $p += $len + 12;
    }
    return (\@found, $out);
}

for my $f (@ARGV) {
    my $d = rd($f);
    my ($found, $out) = substr($d, 0, 2) eq "\xFF\xD8" ? do_jpeg($f, $d)
                      : substr($d, 0, 8) eq "\x89PNG\r\n\x1a\n" ? do_png($f, $d) : ([], $d);
    printf "%s\n%s", $f, @$found ? join('', map { "    $_\n" } @$found) : "    (none)\n";
    if ($mode eq 'strip' && $out ne $d) { wr($f, $out); printf "    -> stripped %d -> %d bytes\n", length $d, length $out }
}
