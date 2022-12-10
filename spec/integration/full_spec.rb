# frozen_string_literal: true

require 'spec_helper'

describe 'full' do
  let(:mongo_db_atlas_client) do
    MongoDBAtlasClient.new
  end

  let(:component) do
    var(role: :full, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :full, name: 'deployment_identifier')
  end
  let(:project_id) do
    output(role: :full, name: 'project_id')
  end

  before(:context) do
    apply(role: :full)
  end

  after(:context) do
    destroy(
      role: :full,
      only_if: -> { !ENV['FORCE_DESTROY'].nil? || ENV['SEED'].nil? }
    )
  end

  describe 'cluster' do
    let(:cluster) do
      mongo_db_atlas_client
        .get_one_cluster(
          project_id,
          "#{component}-#{deployment_identifier}"
        )
    end

    it 'creates a cluster in the specified project' do
      expect(cluster)
        .to(include(
              'name' => "#{component}-#{deployment_identifier}",
              'groupId' => project_id
            ))
    end

    it 'uses the provided cluster type' do
      expect(cluster['clusterType']).to(eq('REPLICASET'))
    end

    it 'uses the provided major version' do
      expect(cluster['mongoDBMajorVersion']).to(eq('6.0'))
    end

    it 'uses the disk size in gigabytes' do
      expect(cluster['diskSizeGB']).to(eq(100))
    end

    it 'uses the specified number of shards' do
      expect(cluster['replicationSpecs'][0]['numShards']).to(eq(1))
    end

    it 'uses the specified compute auto-scaling configuration' do
      expect(cluster['autoScaling']['compute'])
        .to(include(
              'enabled' => true,
              'scaleDownEnabled' => true
            ))
    end

    it 'uses the specified storage auto-scaling configuration' do
      expect(cluster['autoScaling']['diskGBEnabled']).to(be(true))
    end

    it 'uses AWS in the specified region' do
      expect(cluster['providerSettings'])
        .to(include(
              'providerName' => 'AWS',
              'regionName' => 'EU_WEST_1'
            ))
    end

    it 'uses the specified provider instance size' do
      expect(cluster['providerSettings']['instanceSizeName']).to(eq('M30'))
    end

    it 'uses the specified provider auto scaling configuration' do
      auto_scaling_settings =
        cluster['providerSettings']['autoScaling']['compute']

      expect(auto_scaling_settings)
        .to(include(
              'minInstanceSize' => 'M30',
              'maxInstanceSize' => 'M40'
            ))
    end

    it 'uses the specified provider disk iops' do
      expect(cluster['providerSettings']['diskIOPS']).to(eq(3000))
    end

    it 'uses the specified provider volume type' do
      expect(cluster['providerSettings']['volumeType']).to(eq('STANDARD'))
    end

    it 'uses the specified flag for whether or not provider backups ' \
       'are enabled' do
      expect(cluster['providerBackupEnabled']).to(be(true))
    end
  end

  describe 'database users' do
    let(:database_users) do
      [
        {
          username: 'user-1',
          password: 'password-1',
          roles: [
            {
              role_name: 'readAnyDatabase',
              database_name: 'admin',
              collection_name: ''
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
        },
        {
          username: 'user-2',
          password: 'password-2',
          roles: [
            {
              role_name: 'dbAdmin',
              database_name: 'specific',
              collection_name: ''
            }
          ],
          labels: {}
        }
      ]
    end

    it 'creates the requested database users' do
      database_users.each do |database_user|
        found_database_user =
          mongo_db_atlas_client
          .get_one_database_user(project_id, database_user[:username])

        # required to protect against not found response
        expect(found_database_user['username'])
          .to(eq(database_user[:username]))
      end
    end

    it 'adds all requested roles to database users' do
      database_users.each do |database_user|
        found_database_user =
          mongo_db_atlas_client
          .get_one_database_user(project_id, database_user[:username])
        found_roles = found_database_user['roles']

        database_user[:roles].each do |role|
          matching_role = found_roles.find do |found_role|
            found_role['roleName'] == role[:role_name]
          end

          expected_database_name =
            role[:database_name] == '' ? nil : role[:database_name]
          expected_collection_name =
            role[:collection_name] == '' ? nil : role[:collection_name]

          expect(matching_role)
            .to(include(
                  {
                    'databaseName' => expected_database_name,
                    'collectionName' => expected_collection_name
                  }.compact
                ))
        end
      end
    end

    it 'adds all requested labels to database users' do
      database_users.each do |database_user|
        found_database_user =
          mongo_db_atlas_client
          .get_one_database_user(project_id, database_user[:username])
        found_labels = found_database_user['labels']

        database_user[:labels].each do |key, value|
          matching_label = found_labels.find do |found_label|
            found_label['key'] == key.to_s
          end

          expect(matching_label['value']).to(eq(value))
        end
      end
    end

    it 'adds default labels to database users' do
      database_users.each do |database_user|
        found_database_user =
          mongo_db_atlas_client
          .get_one_database_user(project_id, database_user[:username])
        found_labels = found_database_user['labels']

        {
          'Component' => component,
          'DeploymentIdentifier' => deployment_identifier
        }.each do |key, value|
          matching_label = found_labels.find do |found_label|
            found_label['key'] == key
          end

          expect(matching_label['value']).to(eq(value))
        end
      end
    end

    it 'adds a scope for the created cluster' do
      database_users.each do |database_user|
        found_database_user =
          mongo_db_atlas_client
          .get_one_database_user(project_id, database_user[:username])
        found_scopes = found_database_user['scopes']

        expect(found_scopes)
          .to(contain_exactly(
                a_hash_including(
                  'type' => 'CLUSTER',
                  'name' => "#{component}-#{deployment_identifier}"
                )
              ))
      end
    end
  end
end
