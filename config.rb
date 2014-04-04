DEFAULTLANG = 'ru'

@github_token = '33deedd6f4d1ac97eb9e74e277a139861df677a4'

###
# Blog settings
###

LANGUAGES = ['de', 'en', 'es', 'fr', 'gr', 'id', 'it', 'jp', 'kr', 'nl', 'pl', 'pt', 'ru', 'zh', 'ro', 'ar', 'da', 'hr', 'ms', 'tr', 'am', 'th', 'uk']

S3_URL = 'https://s3.amazonaws.com/DiscoverMeteor/'
LANG = ENV['DMLANG'] || DEFAULTLANG

parts = (ENV['TOGO'] || "01:0,02:0,02s:0,03:0,03s:0,04:1,04s:0,05:72,05s:33,06:27,06s:20,07:60,07s:28,08:29,08s:16,09:31,09s:22,10:34,10s:15,11:25,11s:29,12:67,13:49,13s:36,14:58,14s:24").split(',').map{|s| s.split(':')}.flatten
TOGO = Hash[Hash[*parts].map{|key,value| [key.sub(/^0+/, '').sub("s", ".5"), value]}]
p TOGO

@togo = TOGO

@strings = data.strings.find{|s| s['lang'] == 'en'}.merge(data.strings.find{|s| s['lang'] == LANG})

# Time.zone = "UTC"

activate :blog do |blog|
  blog.sources = "chapters/"+LANG+"/:title.html"
  blog.permalink = "chapters/{slug}"
end

# Ignore special markdown files as well a inactive languages

ignore "chapters/"+LANG+"/README.html"
ignore "chapters/"+LANG+"/COMMON.html"

LANGUAGES.each do |language|
  if language != LANG
    ignore "chapters/"+language+"/*"
  end
end

page "chapters/*", :layout => :page_layout

page "/full.html", :layout => :ebook_layout
page "/excerpt.html", :layout => :ebook_layout
page "/pdf.html", :layout => :ebook_layout
page "/sample.html", :layout => :ebook_layout

page "api.html", :layout => :api_layout

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

set :fonts_dir, 'fonts'

set :build_dir, 'tmp'

activate :livereload

activate :directory_indexes

activate :syntax#,:linenos => 'table'

set :markdown_engine, :redcarpet
set :markdown, :fenced_code_blocks => true, :smartypants => true

activate :autoprefixer

helpers do
  def div(css_class, content)
    %Q{<div class="#{css_class}">#{content}</div>}
  end
  def caption(content)
    %Q{<div class="caption">#{content}</div>}
  end
  def image(src, css_class)
    %Q{<img class="#{css_class}" src="/images/#{src}"/>}
  end
  def figure(src, caption="", css_class="")
    %Q{<figure class="#{css_class}"><img src="/images/#{src}"/><figcaption>#{caption}</figcaption></figure>}
  end  
  def diagram(name, caption, css_class="")
    %Q{<figure class="diagram #{css_class}"><img src="#{S3_URL}diagrams/#{name}@2x.png" alt="#{caption}"/><figcaption>#{caption}</figcaption></figure>}
  end
  def screenshot(name, caption, css_class="")
    %Q{<figure class="screenshot #{css_class}"><img src="#{S3_URL}screenshots/#{name}.png" alt="#{caption}"/><figcaption>#{caption}</figcaption></figure>}
  end    
  def commit(name, caption)
    caption = truncate(caption, :length => 60)
    %Q{<div class="commit"><img src="/images/code.svg"/><div class="message"><h4>Commit #{name}</h4><p>#{caption}</p></div><div class="actions"><a class="commit-link" href="https://github.com/DiscoverMeteor/Microscope/commit/chapter#{name}" target="_blank">#{@strings.view_on_github}</a><a class="instance-link" href="http://meteor-book-chapter#{name}.meteor.com" target="_blank" class="live-instance">#{@strings.launch_instance}</a></div></div>}
  end  
  def scommit(name, caption)
    caption = truncate(caption, :length => 60)
    %Q{<div class="commit"><img src="/images/code.svg"/><div class="message"><h4>Commit #{name}</h4><p>#{caption}</p></div><div class="actions"><a class="commit-link" href="https://github.com/DiscoverMeteor/Microscope/commit/sidebar#{name}" target="_blank">#{@strings.view_on_github}</a><a class="instance-link" href="http://meteor-book-sidebar#{name}.meteor.com" target="_blank" class="live-instance">#{@strings.launch_instance}</a></div></div>}
  end    
  def highlight(lines, css_class="added")
    %Q{<div class="lines-highlight" data-lines="#{lines}" data-class="#{css_class}"></div>}
  end
  def pullquote(content, css_class="left")
    %Q{<blockquote class="pull pull-#{css_class}">#{content}</blockquote>}
  end        
  def note(&block)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :fenced_code_blocks => true)
    content = markdown.render(capture(&block))
    concat %Q{<div class="note">#{content}</div>}
  end
  def chapter(&block)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :fenced_code_blocks => true)
    content = markdown.render(capture(&block))
    concat %Q{<div class="note chapter"><h3>In this chapter, you will:</h3>#{content}</div>}
  end
end
