require 'spec_helper'

describe 'Cluster' do
  let(:component) { vars.component }
  let(:deployment_identifier) { vars.deployment_identifier }

  let(:project_id) { output_for(:prerequisites, "project_id", parse: true) }

  let(:cluster_type) { vars.cluster_type }

  context "on AWS" do
    context "for dedicated single cloud single region clusters" do
      before(:all) do
        reprovision(
            provider_name: 'AWS',
            provider_region_name: 'EU_WEST_1',
            provider_instance_size: 'M10')
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

      it 'uses AWS in the specified region' do
        expect(cluster["providerSettings"]["providerName"]).to(eq('AWS'))
        expect(cluster["providerSettings"]["regionName"]).to(eq('EU_WEST_1'))
      end

      it 'uses the specified instance size' do
        expect(cluster["providerSettings"]["instanceSizeName"]).to(eq('M10'))
      end
    end
  end
end
