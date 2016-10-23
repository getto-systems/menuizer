require 'test_helper'

class MenuizerTest < Minitest::Test
  def _to_h(item,converters=[])
    return unless item
    h = item.to_h
    h.delete(:parent)
    h.delete(:namespace)
    h.delete(:model)
    h.delete(:title)
    h.delete(:path)
    if title = item.title
      h[:title] = title
    end
    if path = item.path
      h[:path] = path
    end
    converters.each do |key|
      h.delete(key)
      if value = item.send(key)
        h[key] = value
      end
    end
    if children = h.delete(:children)
      h[:children] = children.map{|i| _to_h(i)}
    end
    h
  end

  def setup
    ::I18n.load_path = Dir[File.expand_path("../locales/*.yml",__FILE__)]
    ::I18n.default_locale = :ja
    ::I18n.backend.load_translations

    Menuizer.send(:config).clear
    Menuizer.configure do |config|
      config.file_path = File.expand_path("../config.yml", __FILE__)
      config.generator = {
        items: ->(menu){
          [
            {item: "items menu item1"},
            {item: "items menu item2",children:[
              {item: "items menu item3"},
            ]},
          ]
        },
        with_data: ->(menu){
          [
            {item: menu.data[:with_data_title]},
          ]
        },
      }
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::Menuizer::VERSION
  end

  def test_build_menues
    menu = Menuizer.menu(with_data_title: "with_data title")
    expected = [
      {type: :header, title: "MAIN NAVIGATION"},
      {type: :tree, item: "Dashboard", title: "Dashboard", children: [
        {type: :item, item: "Dashboard v1", title: "Dashboard v1"},
        {type: :item, item: "Dashboard v2", title: "Dashboard v2"},
      ]},
      {type: :item, item: "widget", icon: "fa fa-th", title: "Widget Title"},
      {type: :tree, item: "tree menu", title: "tree menu", children: [
        {type: :tree, item: "nested menu", title: "nested menu", children: [
          {type: :item, item: :nested_item, title: "nested item title", path: [:nested_item]},
        ]},
        {type: :item, item: "items menu item1", title: "items menu item1"},
        {type: :tree, item: "items menu item2", title: "items menu item2", children: [
          {type: :item, item: "items menu item3", title: "items menu item3"},
        ]},
      ]},
      {type: :item, item: "items menu item1", title: "items menu item1"},
      {type: :tree, item: "items menu item2", title: "items menu item2", children: [
        {type: :item, item: "items menu item3", title: "items menu item3"},
      ]},
      {type: :item, item: "with_data title", title: "with_data title"},
    ]
    assert_equal expected, menu.items.map{|i| _to_h(i)}
    assert_equal expected[2], _to_h(menu.item("widget"))
    assert_equal expected[3], _to_h(menu.item("tree menu"))
  end
  def test_activate
    menu = Menuizer.menu
    menu.activate :nested_item
    expected = {type: :item, item: :nested_item, title: "nested item title", path: [:nested_item], is_active: true}
    assert_equal expected, _to_h(menu.active_item)

    expected = [
      {type: :tree, item: "tree menu", title: "tree menu", children: [
        {type: :tree, item: "nested menu", title: "nested menu", children: [
          {type: :item, item: :nested_item, title: "nested item title", path: [:nested_item], is_active: true},
        ], is_active: true},
        {type: :item, item: "items menu item1", title: "items menu item1"},
        {type: :tree, item: "items menu item2", title: "items menu item2", children: [
          {type: :item, item: "items menu item3", title: "items menu item3"},
        ]},
      ], is_active: true},
      {type: :tree, item: "nested menu", title: "nested menu", children: [
        {type: :item, item: :nested_item, title: "nested item title", path: [:nested_item], is_active: true},
      ], is_active: true},
      {type: :item, item: :nested_item, title: "nested item title", path: [:nested_item], is_active: true},
    ]
    assert_equal expected, menu.active_items.map{|i| _to_h(i)}
  end

  def test_namespace
    namespace = :namespace
    Menuizer.configure(namespace) do |config|
      config.file_path = File.expand_path("../config/namespace.yml", __FILE__)
      config.converter = {
        icon: ->(icon,opts){
          case
          when !icon then "fa fa-circle-o"
          else "fa fa-#{icon}"
          end
        },
      }
    end
    assert_kind_of Menuizer::Menu, Menuizer.menu
    assert_kind_of Menuizer::Menu, Menuizer.menu(namespace)
    assert_kind_of Menuizer::Menu::ItemDefault, Menuizer.menu.items.first
    assert_kind_of Menuizer::Menu.const_get(:"Item_#{namespace}"), Menuizer.menu(namespace).items.first

    expected = [
      {type: :item, item: "widget", title: "Widget Title", icon: "fa fa-circle-o"},
      {type: :item, item: "menu", title: "menu", path: [namespace,:path,:to,:enverope], icon: "fa fa-enverope"},
    ]
    menu = Menuizer.menu(namespace)
    assert_equal expected, menu.items.map{|i| _to_h(i,[:icon])}
    assert_equal expected, menu.items.map{|i| _to_h(i,[:icon])}
  end
end
