xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0' do
  xml.channel do
    xml.title Refinery::Core.site_name
    xml.description Refinery::Core.site_name + ' ' + @page.title
    xml.link "#{[request.protocol, request.host_with_port].join}#{refinery.url_for(@page.url)}"

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.description render_content(post.body)
        xml.pubDate post.published_at.to_s(:rfc822)
        xml.link "#{[request.protocol, request.host_with_port].join}#{blog_post_path(post)}"
      end
    end
  end
end
