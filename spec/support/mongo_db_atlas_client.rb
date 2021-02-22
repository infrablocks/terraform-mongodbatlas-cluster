require 'httparty'
require 'json'

class MongoDBAtlasClient
  def initialize(base_url = nil, username = nil, password = nil)
    @base_url = base_url ||
        ENV["MONGODB_ATLAS_BASE_URL"] ||
        'https://cloud.mongodb.com/api/atlas/v1.0'
    @username = username ||
        ENV["MONGODB_ATLAS_PUBLIC_KEY"]
    @password = password ||
        ENV["MONGODB_ATLAS_PRIVATE_KEY"]
  end

  def get_one_database_user(project_id, username)
    JSON.parse(
        get("/groups/#{project_id}/databaseUsers/admin/#{username}").body)
  end

  def get_one_cluster(project_id, cluster_name)
    JSON.parse(
        get("/groups/#{project_id}/clusters/#{cluster_name}").body)
  end

  private

  def get(path, headers = {})
    HTTParty.get(
        "#{@base_url}#{path}",
        default_headers.merge(headers))
  end

  def default_headers
    {
        digest_auth: credentials
    }
  end

  def credentials
    {
        username: @username,
        password: @password
    }
  end
end