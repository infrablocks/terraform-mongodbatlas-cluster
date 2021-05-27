require 'spec_helper'

describe 'Users' do
  let(:component) { vars.component }
  let(:deployment_identifier) { vars.deployment_identifier }

  let(:database_users) { vars.database_users }

  let(:project_id) { output_for(:prerequisites, "project_id") }

  it 'creates the requested database users' do
    database_users.each do |database_user|
      found_database_user = mongo_db_atlas_client
          .get_one_database_user(project_id, database_user["username"])

      # required to protect against not found response
      expect(found_database_user["username"])
          .to(eq(database_user["username"]))
    end
  end

  it 'adds all requested roles to database users' do
    database_users.each do |database_user|
      found_database_user = mongo_db_atlas_client
          .get_one_database_user(project_id, database_user["username"])
      found_roles = found_database_user["roles"]

      database_user["roles"].each do |role|
        found_role = found_roles.find do |found_role|
          found_role["roleName"] == role["role_name"]
        end

        expected_database_name =
            role["database_name"] == "" ? nil : role["database_name"]
        expected_collection_name =
            role["collection_name"] == "" ? nil : role["collection_name"]

        expect(found_role["databaseName"]).to(eq(expected_database_name))
        expect(found_role["collectionName"]).to(eq(expected_collection_name))
      end
    end
  end

  it 'adds all requested labels to database users' do
    database_users.each do |database_user|
      found_database_user = mongo_db_atlas_client
          .get_one_database_user(project_id, database_user["username"])
      found_labels = found_database_user["labels"]

      database_user["labels"].each do |key, value|
        found_label = found_labels.find do |found_label|
          found_label["key"] == key
        end

        expect(found_label["value"]).to(eq(value))
      end
    end
  end

  it 'adds default labels to database users' do
    database_users.each do |database_user|
      found_database_user = mongo_db_atlas_client
          .get_one_database_user(project_id, database_user["username"])
      found_labels = found_database_user["labels"]

      {
          "Component" => component,
          "DeploymentIdentifier" => deployment_identifier
      }.each do |key, value|
        found_label = found_labels.find do |found_label|
          found_label["key"] == key
        end

        expect(found_label["value"]).to(eq(value))
      end
    end
  end

  it 'adds a scope for the created cluster' do
    database_users.each do |database_user|
      found_database_user = mongo_db_atlas_client
          .get_one_database_user(project_id, database_user["username"])
      found_scopes = found_database_user["scopes"]

      expect(found_scopes.length).to(eq(1))
      expect(found_scopes[0]["type"]).to(eq("CLUSTER"))
      expect(found_scopes[0]["name"])
          .to(eq("#{component}-#{deployment_identifier}"))
    end
  end
end
