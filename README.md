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
    - item: :admins
      icon: fa fa-circle-o
    - item: :users
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
      # or, pass data
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
<% menuizer.activate :admins # item's value %>
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
  <% menuizer.items.each do |item| %>
    <%= render "menu", item: item %>
  <% end %>
</ul>
...
```

```erb
<%
  item # menuizer.items's item
%>
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
      <% item.children.each do |item| %>
        <%= render "layouts/manage/menu", item: item %>
      <% end %>
    </ul>
  </li>
<% end %>
```

### get item

```ruby
menuizer.item(:widgets) #=> menu item
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
    icon: ->(icon,opts){
      case
      when icon.blank? || icon.starts_with?("fa") then icon
      when icon then "fa fa-#{icon}"
      else
        "fa fa-circle-o"
      end
    },
  }
end
```

```ruby
menuizer.items.each do |item|
  item.icon #=> "fa fa-circle-o" <= converter[:icon].call(icon,opts)
end
```

icon, opts is yaml's original value  
opts: all key-value hash


### auto converters

**title**

if not specified, translate by i18n:

```ruby
I18n.translate "menuizer.#{item}", defaults: ["activerecord.models.#{item}","#{item}"
```

**path**

if not specified, and item is symbol: `[namespace,item]`

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
- item: :admins
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

