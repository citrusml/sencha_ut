source "https://rubygems.org"
gem "jekyll"
group :jekyll_plugins do
  gem "jekyll-feed"
  gem "jekyll-seo-tag"
  gem "jekyll-sitemap"
end

# Windows にはタイムゾーンのデータがないので、_config.yml の timezone を使うために必要
platforms :windows, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end