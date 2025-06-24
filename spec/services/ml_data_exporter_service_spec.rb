RSpec.describe MlDataExporterService, type: :service do
  describe ".export" do
    subject(:export) { MlDataExporterService.export }

    let(:export_path) { MlDataExporterService::EXPORT_PATH }
    let(:num_assignments) { rand(1..7) }
    let(:csv_data) { CSV.read(export_path, headers: true) }
    let(:logger) { instance_double("Logger")}
    let(:assignments) do
      build_list(:assignment, num_assignments,
        ride: create(:ride, ride_duration: 15, ride_earnings: 100),
        commute_duration: 5,
        score: 90
      )
    end

    before { allow(Rails).to receive(:logger).and_return(logger) }

    after { File.delete(export_path) if File.exist?(export_path) }

    context "when success" do
      before do
        allow(logger).to receive(:info)
        assignments.each(&:save!)
        export
      end

      it "creates a log" do
        expect(logger).to have_received(:info).with("MlDataExporterService.export Success")
      end

      it "creates a CSV file" do
        expect(File).to exist(export_path)
      end

      it "writes the correct headers to the CSV file" do
        expect(csv_data.headers).to eq(MlDataExporterService::CSV_HEADERS)
      end

      it "writes the correct data to the CSV file" do
        expect(csv_data.length).to eq(num_assignments)
      end

      it "removes temporary files after execution" do
        temp_files_before = Dir.glob("#{Dir.tmpdir}/assignment_data*.csv").count

        export

        temp_files_after = Dir.glob("#{Dir.tmpdir}/assignment_data*.csv").count

        expect(temp_files_after).to eq(temp_files_before)
      end
    end

    context "when an error occurs" do
      before do
        allow(logger).to receive(:error)
        export
      end

      it "creates a log" do
        expect(logger).to have_received(:error).with(a_string_including("MlDataExporterService Unexpected error:"))
      end

      it "does NOT create a CSV file" do
        expect(File).not_to exist(export_path)
      end
    end
  end
end
