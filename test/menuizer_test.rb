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
    Menuizer.send(:map).clear
    Menuizer.send(:config).clear
    Menuizer.configure do |config|
      config.file_path = File.expand_path("../config.yml", __FILE__)
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
      ]},
    ]
    assert_equal expected, menu.items.map{|i| _to_h(i)}
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
      ], is_active: true},
      {type: :tree, title: "nested menu", children: [
        {type: :item, title: "nested items", path: :path_to_somewhere, is_active: true},
      ], is_active: true},
      {type: :item, title: "nested items", path: :path_to_somewhere, is_active: true},
    ]
    assert_equal expected, menu.active_items.map{|i| _to_h(i)}
  end

  def test_namespace
    Menuizer.configure(:namespace) do |config|
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
    assert_kind_of Menuizer::Menu, Menuizer.menu(:namespace)
    assert_kind_of Menuizer::Menu::Item_namespace, Menuizer.menu(:namespace).items.first

    expected = [
      {type: :item, title: "human Widget name", path: :namespace_widgets, icon: "fa fa-circle-o"},
      {type: :item, title: "menu", icon: "fa fa-enverope"},
    ]
    assert_equal expected, Menuizer.menu(:namespace).items.map{|i| _to_h(i,[:icon])}
  end
end
