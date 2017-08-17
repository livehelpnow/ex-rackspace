defmodule RackspaceTest do
  use ExUnit.Case
  require Logger
  alias Rackspace.Api.CloudFiles.Container
  alias Rackspace.Api.CloudFiles.Object

  @container_name "ex_rackspace_test"
  @region "ORD"
  @no_container %Rackspace.Api.CloudFiles.Container{name: nil, bytes: 0, count: 0}

  test "should get a list of containers in cloud files" do
    containers = Container.list()
    assert is_list(containers)
    containers = Container.list(region: @region)
    assert is_list(containers)
  end

  test "should create non existing cloud files container" do
    _ = Container.delete(@container_name, region: @region)
    container = Container.list(region: @region)
      |> Enum.find(@no_container, fn(c) -> c.name == @container_name end)
      
    assert {:ok, :created} = Container.put(@container_name, region: @region)

    assert @container_name = Container.list(region: @region)
      |> Enum.find(@no_container, fn(c) -> c.name == @container_name end)
      |> Map.get(:name)

    _ = Container.delete(@container_name, region: @region)

  end

  test "should put file into cloud files container " do
    #prepare container
    container_name = "ex_rackspace_test_2"
    object_name = "test_file.txt"
    # delete if exists
    _ = Container.delete(container_name, region: @region)
    container = Container.list(region: @region)
      |> Enum.find(@no_container, fn(c) -> c.name == container_name end)
      
    # put the text file
    assert {:ok, :created} = Container.put(container_name, region: @region)
    assert {:ok, :created} = Object.put(container_name, object_name, <<84, 69, 83, 84>>, region: @region)
    assert %Object{
      name: ^object_name, 
      bytes: 4, 
      container: ^container_name, 
      data: "TEST"} = Object.get(container_name, object_name, region: @region)
    
    _ = Container.delete(container_name, region: @region)

  end
end
