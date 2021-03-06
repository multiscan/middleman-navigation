module Middleman::Features::Navigation
  class << self
    def registered(app)
      app.helpers HelpersMethods
      Page.set_app(app)
    end
    alias :included :registered
  end

  module HelpersMethods
    # create a list item containing the link to a given page. 
    # If page is the current one, only a span is Class "selected" is added if the page is the current one.
    def menu_item(page, options={:li_class=>''})
      _options = {
        :selected => {:class => "active"},
        :wrapper => "%s"
      }
      options = _options.merge(options)
      
      mylabel = options[:label] || page.label
      
      if page==request.path
        options[:li_class] += ' ' + options[:selected][:class]
        link = content_tag :span, mylabel
      else
        link = link_to(mylabel, page.url)
      end
      link = options[:wrapper] % link

      return content_tag :li, link, :class => options[:li_class].strip
    end

    # create an <ul> list with links to all the parent pages down to the root
    def trail_nav(sep="<li class='separator'><span>&gt;</span></li>")
      p = Page.new(request.path)
      res=Array.new 
      res << menu_item(p)
      while p=p.parent
        res << sep
        res << menu_item(p)
      end
      return "<ul>" + res.reverse.join(" ") + "</ul>"
    end
    
    def children_nav
      return menu('main')
    end
    
    # create an <ul> list with links to all the childrens of the current page
    def menu(menu, options={})
      p = Page.new(request.path)
      return nil unless p.index?
      return nil if p.nonav?
      c = p.childrens.delete_if{ |m| m.hidden? || !m.from_menu?(menu) } 
      return nil if c.empty?
      i = 0;
      menu_content = c.sort{ |a,b| a.weight <=> b.weight }.map{ |cc|
        i += 1
        item_class = (i == 1) ? 'first' : ''
        item_class += ' last' if c.length == i
        options[:li_class] = item_class
        menu_item(cc, options)
      }.join("\n")
      options.delete(:li_class)
      options.delete(:wrapper)
      return content_tag :ul, menu_content, options
    end
    
    # image tag for the image having the same path as the current page except that it is on /images/banner
    def banner_img(opts={:width=>700, :height=>120})
      p = Page.new(request.path)
      image_tag p.banner_url, opts
    end
    
  end
  # ---------------------------------------------------------------------------
  # This class is for convenient navigation on the site structure
  # It is probably something that could be avoided by knowing a bit more the 
  # internals of mm but, as usual, I have more fun writing a simple class than
  # digging into someone else's code.
  # The only "special" part is that it uses some of the front_matter data
  # for changing the way navigation is generated. In particular
  # nonav : BOOL     if true the children navigation is not build
  # weight : INT     higher weight means the page comes earlier in the menu
  # ---------------------------------------------------------------------------
  class Page
    attr_reader :debug, :path
    def self.set_app(a)
      @@app=a
      @@settings=a.settings
    end
    
    # TODO: how access settings without having to pass them to constructor ?
    def initialize(_path)
      @path = sanitize_path(_path)
      @srcfile = src_from_path(@path)
      @is_index = ! %r{#{@@settings.index_file}$}.match(@path).nil?
      @is_home =  @path=="/" || @path=="/#{@@settings.index_file}"
      @filename_hidden = File.basename(@path, ".html")[-1]=="_" || File.basename(@path, ".html")[0]=="_" || File.basename(File.dirname(@path))[0]=="_"
      @source_dir = File.join(@@settings.root, 'source');
      @banner_url = nil
      @childrens = nil
      @metadata = nil
    end

    def == (other)
      other_path = other.class==Page ? other.path : sanitize_path(other)
      path_test = @path.sub(/\.html$/, '')
      ( other_path =~ Regexp.new(path_test) ) == 0
    end


    # # return the address to the image with the same path as this page from images/banner/
    # def banner_url
    #   return @banner_url unless @banner_url.nil?
    #   p= "/" + @@settings.images_dir + "/banner" + @path.gsub(/\.html$/, ".jpg")
    #   unless File.exists?(@@settings.views + p)
    #     p = parent ? parent.banner_url : "/" + @@settings.images_dir + "/banner/default.jpg"
    #   end
    #   @banner_url = p
    #   return @banner_url
    # end
    
    def url
      return @path
    end

    # return the list of childrent Page objects or nil if this is a leaf node (!@is_index)
    def childrens
      return nil unless index?
      return @childrens unless @childrens.nil?

      # srcfiles=Dir.glob("#{@source_dir}/*.html.haml")
      srcdir=File.dirname(@srcfile)
      srcfiles=Dir.glob("#{srcdir}/*.haml") + Dir.glob("#{srcdir}/*/#{@@settings.index_file}.haml")
      paths=srcfiles.delete_if{|f| f==@srcfile}.map{|f| path_from_src(f) }
      @childrens = paths.map { |p| Page.new(p) }
      return @childrens
    end

    # nicer getter
    def home?
      @is_home
    end

    # nicer getter
    def hidden?
      set_metadata unless @metadata
      @metadata['hidden'] || @filename_hidden
    end

    def from_menu?(menu)
      return menu_scope == menu
    end

    # nicer getter
    def index?
      @is_index
    end
    
    def menu_scope
      set_metadata unless @metadata
      return @metadata['menu_scope'] || 'main'
    end

    # metadata getters
    def nonav?
      set_metadata unless @metadata
      return @metadata['nonav'] || false
    end

    def label
      set_metadata unless @metadata
      return @metadata['label'] || @label
    end
    
    # return the parent Page object or nil if this is the root node (@is_home)
    def parent
      return nil if @is_home
      return @parent unless @parent.nil?
      parent_path = File.dirname(@is_index ? File.dirname(@path) : @path) + "/" + @@settings.index_file
      @parent = Page.new(parent_path)
      return @parent
    end

    #return the label
    def label
      set_metadata unless @metadata
      _label = @is_home ? "HOME" : File.basename(@is_index ? File.dirname(path) : @path, ".html").gsub("_", " ").upcase
      @metadata['menu_title'] || _label
    end

    def weight
      set_metadata unless @metadata
      return @metadata['weight'] || 9999
    end
    
    # return the address to the image with the same path as this page from images/banner/
    def banner_url
      return @banner_url unless @banner_url.nil?
      p= "/" + @@settings.images_dir + "/banner" + @path.gsub(/\.html$/, ".jpg")
      unless File.exists?(@@settings.views + p)
        p = parent ? parent.banner_url : "/" + @@settings.images_dir + "/banner/default.jpg"
      end
      @banner_url = p
      return @banner_url
    end
    
   private

    def path_from_src(path) 
      path.gsub(/\.haml$/,"").gsub(/^#{@@settings.views}/,"")
    end

    # standardize the path. Also prepends "/" for compatibility with mm 1.2
    # TODO: work with relative paths instead (possibly checking user config)
    def sanitize_path(path)
      p="/" + path
      p << "/" + @@settings.index_file unless path.match(%r{\.html$})
      return p.gsub(%r{//*}, "/")
    end

    def set_metadata
      return if @metadata
      @metadata, src = @@app.parse_front_matter(File.read(@srcfile))
      return @metadata
    end

    def src_from_path(path)
      @@settings.views + path + ".haml"
    end
  end
end
