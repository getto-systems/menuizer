require 'test_helper'

class MenuizerTest < Minitest::Test
  class Widget
    def self.model_name
      OpenStruct.new(human: "human Widget name", plural: "widgets")
    end
  end

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
    Menuizer.send(:config).clear
    Menuizer.configure do |config|
      config.file_path = File.expand_path("../config.yml", __FILE__)
      config.generator = {
        items: ->{
          [
            {item: "items menu item1"},
            {item: "items menu item2",children:[
              {item: "items menu item3"},
            ]},
          ]
        }
      }
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::Menuizer::VERSION
  end

  def test_build_menues
    menu = Menuizer.menu
    expected = [
      {type: :header, title: "MAIN NAVIGATION"},
      {type: :tree, title: "Dashboard", children: [
        {type: :item, title: "Dashboard v1"},
        {type: :item, title: "Dashboard v2"},
      ]},
      {type: :item, icon: "fa fa-th", title: "human Widget name", path: :widgets},
      {type: :tree, title: "tree menu", children: [
        {type: :tree, title: "nested menu", children: [
          {type: :item, title: "nested items", path: :path_to_somewhere},
        ]},
        {type: :item, title: "items menu item1"},
        {type: :tree, title: "items menu item2", children: [
          {type: :item, title: "items menu item3"},
        ]},
      ]},
      {type: :item, title: "items menu item1"},
      {type: :tree, title: "items menu item2", children: [
        {type: :item, title: "items menu item3"},
      ]},
    ]
    assert_equal expected, menu.items.map{|i| _to_h(i)}
    assert_equal expected[2], _to_h(menu.item(:"MenuizerTest::Widget"))
    assert_equal expected[3], _to_h(menu.item("tree menu"))
  end
  def test_activate
    menu = Menuizer.menu
    menu.activate "nested items"
    expected = {type: :item, title: "nested items", path: :path_to_somewhere, is_active: true}
    assert_equal expected, _to_h(menu.active_item)

    expected = [
      {type: :tree, title: "tree menu", children: [
        {type: :tree, title: "nested menu", children: [
          {type: :item, title: "nested items", path: :path_to_somewhere, is_active: true},
        ], is_active: true},
        {type: :item, title: "items menu item1"},
        {type: :tree, title: "items menu item2", children: [
          {type: :item, title: "items menu item3"},
        ]},
      ], is_active: true},
      {type: :tree, title: "nested menu", children: [
        {type: :item, title: "nested items", path: :path_to_somewhere, is_active: true},
      ], is_active: true},
      {type: :item, title: "nested items", path: :path_to_somewhere, is_active: true},
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
      {type: :item, title: "human Widget name", path: :"#{namespace}_widgets", icon: "fa fa-circle-o"},
      {type: :item, title: "menu", path: [namespace,:path,:to,:enverope], icon: "fa fa-enverope"},
    ]
    menu = Menuizer.menu(namespace)
    assert_equal expected, menu.items.map{|i| _to_h(i,[:icon])}
    assert_equal expected, menu.items.map{|i| _to_h(i,[:icon])}
  end
end
