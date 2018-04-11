require "../../../spec_helper"

module Amber::Router
  describe Params do
    headers = HTTP::Headers.new
    params = multipart_form_post

    describe "#[]" do
      it "return query string param" do
        params["test"].should eq "test"
      end

      it "returns form data params" do
        params["title"].should eq "title field"
        params["_csrf"].should eq "PcCFp4oKJ1g-hZ-P7-phg0alC51pz7Pl12r0ZOncgxI"
      end

      it "raises error for non existent param" do
        expect_raises Amber::Exceptions::Validator::InvalidParam do
          params["invalid"]
        end
      end

      it "parses int value" do
        params["status"].to_i32.should eq 1234
        params["status"].to_i32?.should eq 1234
      end
    end

    describe "#[]?" do
      it "returns nil for non-existent key" do
        params["invalid"]?.should be_nil
      end

      it "returns value for key" do
        params["test"]?.should eq "test"
      end
    end

    describe "#fetch_all" do
      fetch_all_params = url_encoded_form_post

      it "returns an array of params" do
        fetch_all_params.fetch_all("test").should eq %w(test test2)
      end

      it "works for form params" do
        fetch_all_params.fetch_all("test_form").should eq %w(test1 test2)
      end

      it "prefers query params" do
        fetch_all_params.fetch_all("test_both").should eq %w(query query1)
      end
    end

    describe "#files" do
      it "returns parsed multipart files" do
        params.files["picture"].filename.should eq "index.html"
      end
    end

    describe "#key?" do
      it "returns nil for non-existent key" do
        params.key?("invalid").should be_nil
      end

      it "retuns value for existing key" do
        params.key?("test").should eq "test"
      end
    end

    describe "#override_method?" do
      it "returns override method value" do
        params.override_method?(HTTP::Request::METHOD).should eq "put"
      end

      it "returns nil for nonexistent override method" do
        params.override_method?("non-existent").should be_nil
      end
    end

    describe "#to_h" do
      it "returns a hash with all params" do
        params = multipart_form_post
        params.to_h.keys.should eq %w(test _method status _csrf title content)
        params.to_h["test"].should eq "test"
      end

      it "returns the first value for key" do
        url_encoded_form_post.to_h["cat"].should eq "1"
      end
    end
  end
end

def url_encoded_form_post
  headers = HTTP::Headers.new
  headers["Content-Type"] = "application/x-www-form-urlencoded"
  body = "cat=1&cat=0&cat=-1&test_form=test1&test_form=test2&test_both=form1&test_both=form2"
  request = HTTP::Request.new("GET", 
                              "/?test=test&test=test2&test_both=query&test_both=query1&#{HTTP::Request::METHOD}=put&status=1234",
                              headers,
                              body)
  Amber::Router::Params.new(request)
end

def multipart_form_post
  headers = HTTP::Headers.new
  headers["Content-Type"] = "multipart/form-data; boundary=fhhRFLCazlkA0dX; charset=UTF-8"
  multipart_content = ::File.read(::File.expand_path("spec/support/sample/multipart.txt"))
  multipart_body = multipart_content.gsub("\n", "\r\n")
  request = HTTP::Request.new("POST", "/?test=test&test=test2&#{HTTP::Request::METHOD}=put&status=1234", headers, multipart_body)
  Amber::Router::Params.new(request)
end
