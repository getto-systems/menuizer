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
Menuizer.configure do |menu|
  menu.header "MAIN NAVIGATION"
  menu.item "Dashboard", icon: "fa fa-dashboard" do
    menu.item "Dashboard v1", icon: "fa fa-circle-o"
    menu.item "Dashboard v2", icon: "fa fa-circle-o"
  end

  menu.item Widget, icon: "fa fa-th"

  menu.item "Settings", icon: "fa fa-cog" do
    menu.item Admin, icon: "fa fa-circle-o"
    menu.item User, icon: "fa fa-circle-o", notices: [
      ->{ [:warning, User.unauthorized.count] },
      ->{ [:danger, User.wait.count] },
    ]

    menu.item "nested" do
      menu.item "nested item", path: :path_to_somewhere, icon: "fa fa-circle-o"
    end
  end
end
```

```erb
<%# app/views/admins/index.html.erb %>
<% Menuizer.menu.activate Admin # first argument of menu.item %>
<% content_for :title do %><%= Menuizer.menu.active_item.title %><% end %>

...

<ol class="breadcrumb">
  <% Menuizer.menu.active_items.each do |item| %>
    <li><%= link_to item.path || "#" do %><i class="<%= item.icon %>"></i> <%= item.title %><% end %></li>
  <% end %>
</ol>
```

```erb
<%# app/views/layouts/application.html.erb %>
<title><%= yield :title %></title>

...

<ul class="sidebar-menu">
  <% Menuizer.menu.items.each do |item| %>
    <%= render "menu", item: item %>
  <% end %>
</ul>
```

```erb
<%
  item # Menuizer.menu.items's item
%>
<% case item.type %>
<% when :header %>
  <li class="header"><%= item.title %></li>
<% when :item %>
  <li class="<% if item.is_active %>active<% end %>">
  <%= link_to item.path || "#" do %>
    <i class="<%= item.icon %>"></i> <span><%= item.title %></span>
    <% if item.notices.present? %>
      <% item.notices.each do |notice| %>
        <% type, text = notice.call %>
        <span class="label label-<%= type %> pull-right"><%= text %></span>
      <% end %>
    <% end %>
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

## API

### menu.item

```ruby
menu.item(
  title,     # required : convert to item.title
  path: nil, # optional : convert to item.path

  # other keys pass-through to item.*
  icon: "fa fa-icon",
  notices: [
    ->{ [:info, count] },
  ],
)
```

#### `title` converting

* convert `title.model_name.human` if title respond to `model_name`
* or, leave `title`


#### `path` converting

* convert `:"#{namespace}#{title.model_name.plural}"` if title respond to `model_name`
* or, leave `nil`

**what namespace is?**

↓↓↓

## Multiple namespaces

if your rails application has multiple namespaces, and required multiple menues, pass `:namespace` to Menuizer methods.

```ruby
# config/initializers/menuizer.rb
Menuizer.configure(:namespace) do |menu|
  ...
end
```

```erb
<%# app/views/admins/index.html.erb %>
<% Menuizer.menu(:namespace).activate Admin # first argument of menu.item %>
<% content_for :title do %><%= Menuizer.menu(:namespace).active_item.title %><% end %>

...

<ol class="breadcrumb">
  <% Menuizer.menu(:namespace).active_items.each do |item| %>
    <li><%= link_to item.path || "#" do %><i class="<%= item.icon %>"></i> <%= item.title %><% end %></li>
  <% end %>
</ol>
```

```erb
<%# app/views/layouts/application.html.erb %>
<title><%= yield :title %></title>

...

<ul class="sidebar-menu">
  <% Menuizer.menu(:namespace).items.each do |item| %>
    <%= render "menu", item: item %>
  <% end %>
</ul>
```

## set converter methods

```ruby
# config/initializers/menuizer.rb
Menuizer.configure(:namespace) do |menu|
  menu.set_converter :icon do |icon,opts|
    case
    when icon.blank? || icon.starts_with?("fa") then icon
    when icon then "fa fa-#{icon.to_s.gsub("_","-")}"
    else
      "fa fa-circle-o"
    end
  end
end
```

second argument `opts` : original key-value hash

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/getto-systems/menuizer.

