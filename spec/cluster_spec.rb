require 'spec_helper'

describe 'Cluster' do
  let(:component) { vars.component }
  let(:deployment_identifier) { vars.deployment_identifier }

  let(:project_id) { output_for(:prerequisites, "project_id", parse: true) }

  let(:cluster_type) { vars.cluster_type }

  let(:mongo_db_major_version) { vars.mongo_db_major_version }

  let(:disk_size_gb) { vars.disk_size_gb.to_i }

  let(:auto_scaling) { vars.auto_scaling }

  let(:provider) { vars.provider }

  context "on AWS" do
    context "for dedicated single cloud single region clusters" do
      before(:all) do
        reprovision(
            provider: {
                name: "AWS",
                region_name: "EU_WEST_1",
                instance_size_name: "M10",
                auto_scaling: {
                    compute: {
                        min_instance_size: "M10",
                        max_instance_size: "M30"
                    }
                }
            })
      end

      let(:cluster) {
        mongo_db_atlas_client
            .get_one_cluster(
                project_id,
                "#{component}-#{deployment_identifier}")
      }

      it "creates a cluster in the specified project" do
        expect(cluster["name"]).to(eq("#{component}-#{deployment_identifier}"))
        expect(cluster["groupId"]).to(eq(project_id))
      end

      it 'uses the provided cluster type' do
        expect(cluster["clusterType"]).to(eq(cluster_type))
      end

      it 'uses the provided major version' do
        expect(cluster["mongoDBMajorVersion"]).to(eq(mongo_db_major_version))
      end

      it 'uses the disk size in gigabytes' do
        expect(cluster["diskSizeGB"]).to(eq(disk_size_gb))
      end

      it 'uses the specified auto-scaling configuration' do
        expect(cluster["autoScaling"]["compute"]["enabled"])
            .to(eq(auto_scaling["compute"]["enabled"]))
        expect(cluster["autoScaling"]["compute"]["scaleDownEnabled"])
            .to(eq(auto_scaling["compute"]["scale_down_enabled"]))
        expect(cluster["autoScaling"]["diskGBEnabled"])
            .to(eq(auto_scaling["disk_gb"]["enabled"]))
      end

      it 'uses AWS in the specified region' do
        expect(cluster["providerSettings"]["providerName"]).to(eq('AWS'))
        expect(cluster["providerSettings"]["regionName"]).to(eq('EU_WEST_1'))
      end

      it 'uses the specified provider instance size' do
        expect(cluster["providerSettings"]["instanceSizeName"]).to(eq('M10'))
      end

      it 'uses the specified provider auto scaling configuration' do
        auto_scaling_settings =
            cluster["providerSettings"]["autoScaling"]["compute"]

        expect(auto_scaling_settings["minInstanceSize"]).to(eq("M10"))
        expect(auto_scaling_settings["maxInstanceSize"]).to(eq("M30"))
      end
    end
  end
end
