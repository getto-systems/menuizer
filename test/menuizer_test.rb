require 'test_helper'

class MenuizerTest < Minitest::Test
  class Widget
    def self.model_name
      OpenStruct.new(human: "human Widget name", plural: "widgets")
    end
  end

  def _to_h(item)
    h = item.to_h
    h.delete(:parent)
    h.delete(:namespace)
    h.delete(:title)
    h.delete(:path)
    if title = item.title
      h[:title] = title
    end
    if path = item.path
      h[:path] = path
    end
    if h[:children]
      h[:children] = h[:children].map{|i| _to_h(i)}
    end
    h
  end

  def setup
    Menuizer.configure do |menu|
      menu.header "MAIN NAVIGATION"
      menu.item "Dashboard" do
        menu.item "Dashboard v1"
        menu.item "Dashboard v2"
      end

      menu.item Widget, icon: "fa fa-th"

      menu.item "tree menu" do
        menu.item "nested menu" do
          menu.item "nested items", path: :path_to_somewhere
        end
      end
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::Menuizer::VERSION
  end

  def test_build_menues
    expected = [
      {type: :header, title: "MAIN NAVIGATION"},
      {type: :tree, title: "Dashboard", children: [
        {type: :item, title: "Dashboard v1"},
        {type: :item, title: "Dashboard v2"},
      ]},
      {type: :item, title: "human Widget name", path: :widgets, icon: "fa fa-th"},
      {type: :tree, title: "tree menu", children: [
        {type: :tree, title: "nested menu", children: [
          {type: :item, title: "nested items", path: :path_to_somewhere},
        ]},
      ]},
    ]
    assert_equal expected, Menuizer.menu.items.map{|i| _to_h(i)}
  end
  def test_activate
    Menuizer.menu.activate "nested items"
    expected = {type: :item, title: "nested items", path: :path_to_somewhere, is_active: true}
    assert_equal expected, _to_h(Menuizer.menu.active_item)

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
    assert_equal expected, Menuizer.menu.active_items.map{|i| _to_h(i)}
  end

  def test_namespace
    Menuizer.configure(:namespace) do |menu|
      menu.item Widget
    end
    assert_kind_of Menuizer::Menu, Menuizer.menu
    assert_kind_of Menuizer::Menu, Menuizer.menu(:namespace)
    assert_equal Menuizer.menu, Menuizer.menu
    assert_equal Menuizer.menu(:namespace), Menuizer.menu(:namespace)
    refute_equal Menuizer.menu, Menuizer.menu(:namespace)

    expected = [
      {type: :item, title: "human Widget name", path: :namespace_widgets},
    ]
    assert_equal expected, Menuizer.menu(:namespace).items.map{|i| _to_h(i)}
  end
end
