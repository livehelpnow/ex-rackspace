# Rackspace
API adapter for rackspace services in Elixir

## Usage

Add Rackspace as a dependency in your `mix.exs` file.

```elixir
def deps do
  [{:rackspace, "~> 0.0.1"} ]
end
```

## Configuration
Connection to rackspace API's will require your username and either your account password, or your account api key. It is recommended that you use the api key which can be obtained by logging into your rackspace account.

You can configure the rackspace library by adding a config section to your Application config
```elixir
config :racksapce, :auth,
  api_key: "xxxxxxxxxxxxxx",
  username: "yyyyyyyyyyyyy",
  password: "zzzzzzzzzzzzz"
```

Or by setting environment variables
RS_API_KEY=xxxxxxxxxxxxxx
RS_USERNAME=yyyyyyyyyyyyy
RS_PASSWORD=zzzzzzzzzzzzz

## API

This API is a work in progress. Currently it just supports certain cloud files actions.

### CloudFiles

#### Containers

```elixir
iex> Rackspace.Api.CloudFiles.Container.list
[%Rackspace.Api.CloudFiles.Container{bytes: 0, count: 0, name: "container_name"}]

iex> Rackspace.Api.CloudFiles.Container.create "container-name"
{:ok, %Rackspace.Api.CloudFiles.Container{bytes: 0, count: 0, name: "container_name"}}

iex> Rackspace.Api.CloudFiles.Container.delete "container-name"
{:ok, :deleted}
```

#### Objects

```elixir
iex> Rackspace.Api.CloudFiles.Object.list "container_name"
[%Rackspace.Api.CloudFiles.Object{bytes: 785, container: "container_name",
  content_encoding: nil, content_type: "image/png", data: "", hash: nil,
  last_modified: nil, metadata: [], name: "test.png"}]

iex> Rackspace.Api.CloudFiles.Object.get "container_name", "test.png"
%Rackspace.Api.CloudFiles.Object{bytes: 785, container: "container_name",
 content_encoding: nil, content_type: "image/png",
 data: <<137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 16, 0, 0, 0, 16, 8, 3, 0, 0, 0, 40, 45, 15, 83, 0, 0, 1, 44, 80, 76, 84, 69, 0, 0, 0, 68, ...>>,
 hash: "2e1a60ecf174ae6526e3beae780d04af",
 last_modified: "Sun, 15 Mar 2015 01:24:26 GMT", metadata: [], name: "test.png"}

iex> Rackspace.Api.CloudFiles.Object.put "container_name", "test.png", <<>>
{:ok, :put}
```

## License

   Copyright 2014 LiveHelpNow

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
