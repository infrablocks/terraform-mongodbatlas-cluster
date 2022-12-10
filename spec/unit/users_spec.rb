# frozen_string_literal: true

require 'spec_helper'

describe 'cluster' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :root, name: 'deployment_identifier')
  end
  let(:project_id) do
    output(role: :prerequisites, name: 'project_id')
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root)
    end

    it 'does not create any MongoDB Atlas database users' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'mongodbatlas_database_user'))
    end
  end

  describe 'when no database users specified' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.database_users = []
      end
    end

    it 'does not create any MongoDB Atlas database users' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'mongodbatlas_database_user'))
    end
  end

  describe 'when one database user specified' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.database_users = [
          {
            username: 'user-1',
            password: 'password-1',
            roles: [
              {
                role_name: 'readAnyDatabase',
                database_name: 'admin',
                collection_name: 'stuff'
              },
              {
                role_name: 'readWrite',
                database_name: 'specific',
                collection_name: 'things'
              }
            ],
            labels: {
              important: 'thing',
              something: 'else'
            }
          }
        ]
      end
    end

    it 'creates a MongoDB Atlas database user' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .once)
    end

    it 'uses the provided project ID' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(:project_id, project_id))
    end

    it 'uses the provided username' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(:username, 'user-1'))
    end

    it 'uses the provided password' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(:password, matching(/password-1/)))
    end

    it 'uses an auth database name of "admin"' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(:auth_database_name, 'admin'))
    end

    it 'adds each of the provided roles' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(:roles, containing_exactly(
                                              a_hash_including(
                                                role_name: 'readAnyDatabase',
                                                database_name: 'admin',
                                                collection_name: 'stuff'
                                              ),
                                              a_hash_including(
                                                role_name: 'readWrite',
                                                database_name: 'specific',
                                                collection_name: 'things'
                                              )
                                            )))
    end

    it 'adds each of the provided database user labels' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(
                :labels,
                a_collection_including(
                  a_hash_including(
                    key: 'important',
                    value: 'thing'
                  ),
                  a_hash_including(
                    key: 'something',
                    value: 'else'
                  )
                )
              ))
    end

    it 'adds the default labels' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(
                :labels,
                a_collection_including(
                  a_hash_including(
                    key: 'Component',
                    value: component
                  ),
                  a_hash_including(
                    key: 'DeploymentIdentifier',
                    value: deployment_identifier
                  )
                )
              ))
    end

    it 'adds a scope to the database user for the cluster' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(
                :scopes,
                containing_exactly(a_hash_including(type: 'CLUSTER'))
              ))
    end
  end

  describe 'when labels provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.labels = {
          top: 'level'
        }
        vars.database_users = [
          {
            username: 'user-1',
            password: 'password-1',
            roles: [
              {
                role_name: 'dbAdmin',
                database_name: 'admin',
                collection_name: 'stuff'
              }
            ],
            labels: {
              important: 'thing',
              something: 'else'
            }
          }
        ]
      end
    end

    it 'adds each of the provided top level labels' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(
                :labels,
                a_collection_including(
                  a_hash_including(
                    key: 'top',
                    value: 'level'
                  )
                )
              ))
    end

    it 'adds each of the provided database user labels' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(
                :labels,
                a_collection_including(
                  a_hash_including(
                    key: 'important',
                    value: 'thing'
                  ),
                  a_hash_including(
                    key: 'something',
                    value: 'else'
                  )
                )
              ))
    end

    it 'adds the default labels' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(
                :labels,
                a_collection_including(
                  a_hash_including(
                    key: 'Component',
                    value: component
                  ),
                  a_hash_including(
                    key: 'DeploymentIdentifier',
                    value: deployment_identifier
                  )
                )
              ))
    end
  end

  describe 'when many database users specified' do
    before(:context) do
      @database_user1 = {
        username: 'user-1',
        password: 'password-1',
        roles: [
          {
            role_name: 'readAnyDatabase',
            database_name: 'admin',
            collection_name: 'stuff'
          },
          {
            role_name: 'readWrite',
            database_name: 'specific',
            collection_name: 'things'
          }
        ],
        labels: {
          important: 'thing',
          something: 'else'
        }
      }
      @database_user2 = {
        username: 'user-2',
        password: 'password-2',
        roles: [
          {
            role_name: 'dbAdmin',
            database_name: 'specific',
            collection_name: 'stuff'
          }
        ],
        labels: {}
      }
      @plan = plan(role: :root) do |vars|
        vars.database_users = [@database_user1, @database_user2]
      end
    end

    it 'creates a MongoDB Atlas database user for each specified' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .twice)
    end

    it 'uses the provided project ID' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(:project_id, project_id)
              .twice)
    end

    it 'uses the provided username for each user' do
      [@database_user1, @database_user2].each do |database_user|
        expect(@plan)
          .to(include_resource_creation(type: 'mongodbatlas_database_user')
                .with_attribute_value(:username, database_user[:username]))
      end
    end

    it 'uses the provided password for each user' do
      [@database_user1, @database_user2].each do |database_user|
        expect(@plan)
          .to(include_resource_creation(type: 'mongodbatlas_database_user')
                .with_attribute_value(
                  :password, matching(/#{database_user[:password]}/)
                ))
      end
    end

    it 'uses an auth database name of "admin"' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(:auth_database_name, 'admin')
              .twice)
    end

    it 'adds each of the provided roles for each user' do
      [@database_user1, @database_user2].each do |database_user|
        roles = database_user[:roles]
        roles_matchers = roles.collect { |role| a_hash_including(role) }
        expect(@plan)
          .to(include_resource_creation(type: 'mongodbatlas_database_user')
                .with_attribute_value(
                  :roles, containing_exactly(*roles_matchers)
                ))
      end
    end

    it 'adds each of the provided database user labels' do
      [@database_user1, @database_user2].each do |database_user|
        labels = database_user[:labels]
        labels_matchers = labels.collect do |key, value|
          a_hash_including(
            key: key.to_s,
            value:
          )
        end
        expect(@plan)
          .to(include_resource_creation(type: 'mongodbatlas_database_user')
                .with_attribute_value(
                  :labels,
                  a_collection_including(*labels_matchers)
                ))
      end
    end

    it 'adds the default labels' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(
                :labels,
                a_collection_including(
                  a_hash_including(
                    key: 'Component',
                    value: component
                  ),
                  a_hash_including(
                    key: 'DeploymentIdentifier',
                    value: deployment_identifier
                  )
                )
              )
              .twice)
    end

    it 'adds a scope to the database user for the cluster' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_database_user')
              .with_attribute_value(
                :scopes,
                containing_exactly(a_hash_including(type: 'CLUSTER'))
              )
              .twice)
    end
  end
end
