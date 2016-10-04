require 'test_helper'

class MenuizerTest < Minitest::Test
  class Widget
    def self.model_name
      OpenStruct.new(human: "Widget", plural: "widgets")
    end
  end
  class User
    def self.model_name
      OpenStruct.new(human: "Widget", plural: "widgets")
    end
  end

  def _to_h(item)
    h = item.to_h
    h.delete!(:parent)
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
          menu.item "nested items", path: :path_to_somewhere_path
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
        {type: :item, title: "Dashboard v1", path: nil},
        {type: :item, title: "Dashboard v2", path: nil},
      ]},
      {type: :item, title: "Widget", path: :widgets_path, icon: "fa fa-th"},
      {type: :tree, title: "tree menu", children: [
        {type: :tree, title: "nested menu", children: [
          {type: :item, title: "nested items", path: :path_to_somewhere_path},
        ]},
      ]},
    ]
    assert_equal expected, Menuizer.menu.items.map{|i| _to_h(i)}
  end
  def test_activate
    Menuizer.menu.activate "nested items"
    expected = {type: :item, title: "nested items", path: :path_to_somewhere_path}
    assert_equal expected, _to_h(Menuizer.menu.active_item)

    expected = [
      {type: :item, title: "nested items", path: :path_to_somewhere_path},
      {type: :tree, title: "nested menu", children: [
        {type: :item, title: "nested items", path: :path_to_somewhere_path},
      ]},
      {type: :tree, title: "tree menu", children: [
        {type: :tree, title: "nested menu", children: [
          {type: :item, title: "nested items", path: :path_to_somewhere_path},
        ]},
      ]},
    ]
    assert_equal expected, Menuizer.menu.active_items..map{|i| _to_h(i)}
  end
end
