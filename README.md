# Menuizer

[![Build Status](https://travis-ci.org/getto-systems/menuizer.svg?branch=master)](https://travis-ci.org/getto-systems/menuizer)
[![Gem Version](https://badge.fury.io/rb/menuizer.svg)](https://badge.fury.io/rb/menuizer)

build menu items for admin page ( like AdminLTE )

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'menuizer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install menuizer

## Usage

```ruby
# config/initializers/menuizer.rb
Menuizer.configure do |config|
  config.file_path = Rails.root.join("config/menuizer.yml")
  config.cache = Rails.env.production? # cache yml
end
```

```yaml
# config/menuizer.yml
- header: MAIN NAVIGATION
- item: Dashboard
  path:
    - :root
  icon: fa fa-dashboard
  children: 
    - item: Dashboard v1
      icon: fa fa-circle-o
      path:
        - :dashboard1
    - item: Dashboard v2
      icon: fa fa-circle-o
      path:
        - :dashboard2

- item: :widgets
  icon: fa fa-th

- item: Settings
  icon: fa fa-cog
  children:
    - item: :admin
      icon: fa fa-circle-o
    - item: :user
      icon: fa fa-circle-o

  - item: nested
    children:
      - item: nested item
        icon: fa fa-circle-o
```

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :set_menuizer

  private

    def set_menuizer
      @menuizer = Menuizer.menu
      # or
      # @menuizer = Menuizer.menu(request: request)
      # @menuizer.data[:request] #=> request
    end
    helper_method def menuizer
      @menuizer
    end
end
```

```erb
<%# app/views/admins/index.html.erb %>
<% menuizer.activate :admin # item's value %>
<% content_for :title do %><%= menuizer.active_item.try(:title) %><% end %>

...

<ol class="breadcrumb">
  <% menuizer.active_items.each do |item| %>
    <li><%= link_to item.path || "#" do %><i class="<%= item.icon %>"></i> <%= item.title %><% end %></li>
  <% end %>
</ol>
```

```erb
<%# app/views/layouts/application.html.erb %>
...
<ul class="sidebar-menu">
  <%= render "menu", items: menuizer.items %>
</ul>
...
```

```erb
<%# app/views/application/_menu.html.erb %>
<%
  items # menuizer.items
%>
<% items.each do |item| %>
  <% case item.type %>
  <% when :header %>
    <li class="header"><%= item.title %></li>
  <% when :item %>
    <li class="<% if item.is_active %>active<% end %>">
    <%= link_to item.path || "#" do %>
      <i class="<%= item.icon %>"></i> <span><%= item.title %></span>
    <% end %>
    </li>
  <% else %>
    <li class="<% if item.is_active %>active <% end %>treeview">
      <a href="#">
        <i class="<%= item.icon %>"></i> <span><%= item.title %></span>
        <span class="pull-right-container">
          <i class="fa fa-angle-left pull-right"></i>
        </span>
      </a>
      <ul class="treeview-menu">
        <%= render "menu", items: item.children %>
      </ul>
    </li>
  <% end %>
<% end %>
```

### get item

```ruby
menuizer.item(:admin) #=> menu item
```

### short cut

```yaml
- item: :admin
# =>
# path:
#   - :admins
```

(auto convert path)

## i18n

```yaml
ja:
  menuizer:
    admin: Admin Title
  # or
  activerecord:
    models:
      admin: Admin Title
```

## Generators

Generate menu items by ruby code:

```ruby
# config/initializers/menuizer.rb
Menuizer.configure do |config|
  ...
  config.generator = {
    generate_items: ->(menu){
      [
        {item: "generate item1"},
        {item: "generate item2"},
      ]
    },
  }
end
```

```yaml
# config/menuizer.yml
- header: MAIN NAVIGATION
- items: :generate_items
# =>
# - item: generate item1
# - item: generate item2
```

## Converters

Convert menu item's property:

```ruby
# config/initializers/menuizer.rb
Menuizer.configure do |config|
  config.converter = {
    icon: ->(value,opts){
      # value : item.#{key} value
      # opts  : item yml data
      case
      when !icon then "fa fa-circle-o"
      when value.to_s.blank? || value.to_s.starts_with?("fa") then value
      else "fa fa-#{value}"
      end
    },
  }
end
```

```yaml
- item: no icon
- item: enverope
  icon: enverope
```

```ruby
menuizer.item("no icon").icon  # => "fa fa-circle-o"
menuizer.item("envelope").icon # => "fa fa-envelope"
```

### auto converters

**title**

if not specified, translate by i18n:

```ruby
I18n.translate "menuizer.#{item}", defaults: ["activerecord.models.#{item}","#{item}"
```

**path**

if not specified, and item is symbol: `[namespace,item.to_s.pluralize.to_sym]`

**what is namespace?**

↓↓↓

## Multiple namespaces

If your rails application has multiple namespaces, and required multiple menues, pass `:namespace` to Menuizer methods.

```ruby
# config/initializers/menuizer.rb
Menuizer.configure(:namespace) do |config|
  config.file_path = Rails.root.join("config/menuizer/namespace.yml")
end
```

```yaml
# config/menuizer/namespace.yml
- header: NAMESPACE MENU
- item: :admin
- item: :menu
```

```yaml
# config/locales/menuizer.ja.yml
ja:
  namespace_menuier:
    menu: title
```

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :set_menuizer

  private

    def set_menuizer
      @menuizer = Menuizer.menu(:namespace)
    end
    helper_method def menuizer
      @menuizer
    end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/getto-systems/menuizer.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
