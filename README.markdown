This gem ads simple helpers to [Middleman](http://middlemanapp.com) static site generator 
to add navigation menus and breadcrumbs.

# Installation

1. add the gem in your Gemfile:

        gem "middleman-navigation", :git=>"git://github.com/multiscan/middleman-navigation.git"

2. run bundler

        bundle install

3. include it in your config.rb file

        require middleman-navigation

        activate :navigation

# Usage
The gem add a menu helper to Middleman.

## menu

Automatic generate menu reading pages at project root folder.

Example:
    =menu 'main' [, [options]]


### Metadata
The behaviour of menu can be changed by adding a metadata at head of source files.

Example:
      ---
      nonav: true
      weight: 80
      menu_title: Custom Title
      menu_scope: main
      ---
      Here you have the actual page source

*nonav*: option inhibits the creation of the menu for the current page
*hidden*: option explicitly remove the current page from it's parent menu. By default all pages with an underscore in the beginning or end of their source file name are hidden; 
*weight*: is used to alter the order of the links in the navigation menu (the smaller the weight, the earlier the page will be listed *NOTE: this is the opposite of what the plugin used to do*);
*menu_title*: is used to set a custom title to menu, default to file name;
*menu_scope*: the name of menu that will handle this link

# Problems

* Files ext must be .html.haml (Need fix it);
* Dont search files for generate menu on children folder;
* Current version only works with haml source files;
* No nested navigation yet;
* Not yet compatible with :directory_indexes feature.

# Middleman 3
Most of the code of this plugin is essentially already included in version 3 of the grat middleman.
A quick hack to replace its funcionality is to add the following helpers to your config.rb file:

    helpers do
      class Middleman::Sitemap::Page
        def banner_url
          p= "/" + app.images_dir + "/banner/" + self.path.gsub(/\.html$/, ".jpg")
          unless File.exists?(app.source_dir+p)
            p = self.parent ? self.parent.banner_url : "/" + app.images_dir + "/banner/default.jpg"
          end
          return p
        end
        def nonav?
          self.data && self.data[:nonav]
        end
        def hidden?
          self.data && self.data['hidden'] || File.basename(self.path, ".html")[-1]=="_" || File.basename(self.path, ".html")[0]=="_" || File.basename(File.dirname(self.path))[0]=="_"
        end
        def label
          self.data && self.data['menu_title'] || self.parent.nil? ? "home" : File.basename(self.directory_index? ? File.dirname(self.path) : self.path, ".html").gsub("_", " ")
        end
        def weight
          self.data && self.data['weight'] || 0
        end
      end
  
      def banner_img(opts={:width=>700, :height=>120})
        image_tag current_page.banner_url, opts
      end
  
      # create a list item containing the link to a given page. 
      # If page is the current one, only a span is Class "selected" is added if the page is the current one.
      def menu_item(page, options={:li_class=>''})
        _options = {
          :selected => {:class => "active"},
          :wrapper => "%s"
        }
        options = _options.merge(options)  
        mylabel = options[:label] || page.label
        if page==current_page
          options[:li_class] += ' ' + options[:selected][:class]
          link = content_tag :span, mylabel
        else
          link = link_to(mylabel, "/"+page.path)
        end
        link = options[:wrapper] % link
        return content_tag :li, link, :class => options[:li_class].strip
      end
  
      # create an <ul> list with links to all the childrens of the current page
      def children_nav(options={})
        p = current_page
        return nil unless p.directory_index?
        return nil if p.nonav?
        c = p.children.delete_if{ |m| m.hidden? } 
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
  
      # create an <ul> list with links to all the parent pages down to the root
      def trail_nav(sep="<li class='separator'><span>&gt;</span></li>")
        p = current_page
        res=Array.new 
        res << menu_item(p)
        while p=p.parent
          res << sep
          res << menu_item(p)
        end
        return "<ul>" + res.reverse.join(" ") + "</ul>"
      end  
    end

