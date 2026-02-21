defmodule Gust.ClassesTest do
  use ExUnit.Case

  describe "classes/1" do
    test "string passthrough" do
      assert Gust.classes("p-4 mt-2") == "p-4 mt-2"
    end

    test "list of strings" do
      assert Gust.classes(["p-4", "mt-2"]) == "p-4 mt-2"
    end

    test "list with nil" do
      assert Gust.classes(["p-4", nil, "mt-2"]) == "p-4 mt-2"
    end

    test "nil input" do
      assert Gust.classes(nil) == ""
    end

    test "keyword list conditional inclusion" do
      assert Gust.classes(["font-bold": true, "text-red-500": false]) == "font-bold"
    end

    test "mixed list with keyword conditionals" do
      assert Gust.classes(["p-4", [hidden: true, "font-bold": false]]) == "p-4 hidden"
    end

    test "nested list" do
      assert Gust.classes(["mt-1 mx-2", ["pt-2": true, "pb-4": false]]) == "mt-1 mx-2 pt-2"
    end

    test "same group: last wins" do
      assert Gust.classes(["p-4", "p-2"]) == "p-2"
    end

    test "shorthand dropped when longhand overrides" do
      assert Gust.classes(["p-4", "px-2"]) == "px-2"
    end

    test "conditional conflicts resolved" do
      assert Gust.classes(["p-4", [hidden: true, "p-2": true]]) == "hidden p-2"
    end
  end

  describe "remove/2" do
    test "removes a class from a class string" do
      assert Gust.remove("p-4 mt-2 font-bold", "mt-2") == "p-4 font-bold"
    end

    test "returns unchanged string if class not present" do
      assert Gust.remove("p-4 mt-2", "font-bold") == "p-4 mt-2"
    end
  end

  describe "sigil_t" do
    test "basic string" do
      import Gust
      assert ~t"p-4 mt-2" == "p-4 mt-2"
    end

    test "conflicts are resolved" do
      import Gust
      assert ~t"p-4 p-2" == "p-2"
    end

    test "extra whitespace is normalised" do
      import Gust
      assert ~t"p-4   mt-2" == "p-4 mt-2"
    end

    test "shorthand dropped when longhand overrides" do
      import Gust
      assert ~t"p-4 px-2" == "px-2"
    end
  end
end
