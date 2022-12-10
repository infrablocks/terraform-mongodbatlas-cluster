# frozen_string_literal: true

require 'spec_helper'

describe 'cluster' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :root, name: 'deployment_identifier')
  end
  let(:cloud_provider) do
    var(role: :root, name: 'cloud_provider')
  end
  let(:project_id) do
    output(role: :prerequisites, name: 'project_id')
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root)
    end

    it 'creates a MongoDB Atlas cluster' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .once)
    end

    it 'uses the provided project ID' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(:project_id, project_id))
    end

    it 'includes the component and deployment identifier in the name' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(
                :name,
                including(component)
                  .and(including(deployment_identifier))
              ))
    end

    it 'uses a cluster type of "REPLICASET"' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(:cluster_type, 'REPLICASET'))
    end

    it 'uses a MongoDB major version of "4.4"' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(:mongo_db_major_version, '4.4'))
    end

    it 'does not set a disk size' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(:disk_size_gb, a_nil_value))
    end

    it 'enabled storage auto-scaling' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(:auto_scaling_disk_gb_enabled, true))
    end

    it 'does not enable compute auto-scaling' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(:auto_scaling_compute_enabled, false))
    end

    it 'does not enable compute scale down' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(
                :auto_scaling_compute_scale_down_enabled, false
              ))
    end

    it 'uses the provided cloud provider' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(:provider_name, cloud_provider['name']))
    end

    it 'uses the provided provider region name' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(
                :provider_region_name, cloud_provider['region_name']
              ))
    end

    it 'uses the provided provider instance size name' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(
                :provider_instance_size_name,
                cloud_provider['instance_size_name']
              ))
    end

    it 'uses the provided provider disk IOPS' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(
                :provider_disk_iops,
                cloud_provider['disk_iops']
              ))
    end

    it 'uses the provided provider volume type' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(
                :provider_volume_type,
                cloud_provider['volume_type']
              ))
    end

    it 'uses the provided provider backup enabled setting' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(
                :provider_backup_enabled,
                cloud_provider['backup_enabled']
              ))
    end

    it 'uses 1 shard in the replication specs' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value([:replication_specs, 0, :num_shards], 1))
    end

    it 'uses the provided region name in the replication specs ' \
       'region config' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(
                [:replication_specs, 0,
                 :regions_config, 0,
                 :region_name],
                cloud_provider['region_name']
              ))
    end

    it 'uses 3 electable nodes in the replication specs ' \
       'region config' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(
                [:replication_specs, 0,
                 :regions_config, 0,
                 :electable_nodes],
                3
              ))
    end

    it 'uses a priority of 7 in the replication specs ' \
       'region config' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(
                [:replication_specs, 0,
                 :regions_config, 0,
                 :priority],
                7
              ))
    end

    it 'outputs the cluster ID' do
      expect(@plan)
        .to(include_output_creation(name: 'module_outputs')
              .with_value(including(:cluster_id)))
    end

    it 'outputs the cluster connection strings' do
      expect(@plan)
        .to(include_output_creation(name: 'module_outputs')
              .with_value(including(:connection_strings)))
    end
  end

  describe 'when cluster type is provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.cluster_type = 'WAT'
      end
    end

    it 'uses the provided cluster type' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(:cluster_type, 'WAT'))
    end
  end

  describe 'when MongoDB major version is provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.mongo_db_major_version = '6.0'
      end
    end

    it 'uses the provided major version' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(:mongo_db_major_version, '6.0'))
    end
  end

  describe 'when the disk size in GB is provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.disk_size_gb = 100
      end
    end

    it 'uses the provided major version' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(:disk_size_gb, 100))
    end
  end

  describe 'when the number of shards is provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.number_of_shards = 5
      end
    end

    it 'uses the provided major version' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value([:replication_specs, 0, :num_shards], 5))
    end
  end

  describe 'when auto-scaling configuration is provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.auto_scaling = {
          disk_gb: {
            enabled: false
          },
          compute: {
            enabled: true,
            scale_down_enabled: true
          }
        }
      end
    end

    it 'uses the provided value for whether storage auto-scaling is enabled' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(:auto_scaling_disk_gb_enabled, false))
    end

    it 'uses the provided value for whether compute auto-scaling is enabled' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(:auto_scaling_compute_enabled, true))
    end

    it 'uses the provided value for whether compute scale down is enabled' do
      expect(@plan)
        .to(include_resource_creation(type: 'mongodbatlas_cluster')
              .with_attribute_value(
                :auto_scaling_compute_scale_down_enabled, true
              ))
    end
  end
end
