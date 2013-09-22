require "spec_helper"

describe Bayes::Classifier do
  subject{ Bayes::Classifier.new }

  let(:categories){{
    "category_one" => double(:category1),
    "category_two" => double(:category2),
    "category_three" => double(:category3)
  }}

  describe "#initialize" do
    it "should initialize empty categories hash" do
      subject.instance_variable_get("@categories").should == {}
    end
  end

  describe "#categories" do
    it "should return categories" do
      subject.instance_variable_set("@categories", categories)
      subject.categories.should == categories
    end
  end

  describe "#train" do
    it "should train requested category with provided text" do
      category = double(:category)

      subject.should_receive(:ensure_category).with("the_category_name").and_return(category)
      category.should_receive(:train).with("lorem ipsum dolor")

      subject.train "the_category_name", "lorem ipsum dolor"
    end
  end

  describe "#ensure_category" do
    let(:category){ double(:category) }
    before(:each){ subject.instance_variable_set("@categories", { "the_category_name" => category }) }

    context "if category exists" do
      it "should return requested category" do
        subject.ensure_category("the_category_name").should == category
      end
    end

    context "if category does not exist" do
      it "should create category and return it" do
        new_category = double(:new_category)
        Bayes::Category.should_receive(:new).and_return(new_category)
        subject.ensure_category("another_category_name").should == new_category
        subject.instance_variable_get("@categories")["another_category_name"].should == new_category
      end
    end
  end

  describe "#train_with_array" do
    it "should train requested category with each item from provided array" do
      subject.should_receive(:train).with("the_category_name", "test line 1")
      subject.should_receive(:train).with("the_category_name", "test line 2")
      subject.should_receive(:train).with("the_category_name", "test line 3")

      subject.train_with_array "the_category_name", ["test line 1", "test line 2", "test line 3"]
    end
  end

  describe "#train_with_file" do
    it "should train requested category with lines from provided file" do
      File.should_receive(:read).with("filename.txt").and_return("test line 1\ntest line 2\r\ntest line 3")

      subject.should_receive(:train_with_array).with("the_category_name", ["test line 1", "test line 2", "test line 3"])

      subject.train_with_file "the_category_name", "filename.txt"
    end
  end

  describe "#train_with_csv" do
    it "should train categories from csv file with appropriate string" do
      content = double(:content)
      csv = [
        ["test line 1", "category_one"],
        ["test line 2", "category_one"],
        ["test line 3", "category_two"],
        ["test line 4", "category_one"],
        ["test line 5", "category_two"]
      ]

      File.should_receive(:read).with("filename.csv").and_return(content)
      CSV.should_receive(:new).with(content, col_sep: "||", quote_char: "§").and_return(csv)
      csv.each do |row|
        subject.should_receive(:train).with(row[1], row[0])
      end

      subject.train_with_csv "filename.csv", separator: "||"
    end
  end

  describe "#apply_weighting" do
    it "should apply weighting to requested category" do
      category = double(:category)
      subject.should_receive(:ensure_category).with("the_category_name").and_return(category)
      category.should_receive(:apply_weighting).with(11)

      subject.apply_weighting "the_category_name", 11
    end
  end

  describe "#classify" do
    it "should calculate score for each category and return one with the biggest score" do
      subject.instance_variable_set "@categories", categories

      categories["category_one"].should_receive(:score_for).with(%W{lorem ipsum dolor}).and_return(-10)
      categories["category_two"].should_receive(:score_for).with(%W{lorem ipsum dolor}).and_return(-5)
      categories["category_three"].should_receive(:score_for).with(%W{lorem ipsum dolor}).and_return(-15)

      subject.classify("lorem ipsum dolor").should == "category_two"
    end
  end

  describe "#pop_unused" do
    it "should delete blank categories" do
      subject.instance_variable_set "@categories", categories

      categories["category_one"].should_receive(:blank?).and_return(false)
      categories["category_two"].should_receive(:blank?).and_return(false)
      categories["category_three"].should_receive(:blank?).and_return(true)

      subject.pop_unused
      subject.instance_variable_get("@categories").should == {
        "category_one" => categories["category_one"],
        "category_two" => categories["category_two"]
      }
    end
  end

  describe "#flush" do
    it "should reset each category" do
      subject.instance_variable_set "@categories", categories
      categories.each{ |name, cat| cat.should_receive(:reset) }
      subject.flush
    end
  end

  describe "#flush_all" do
    it "should remove all categories" do
      subject.flush_all
      subject.instance_variable_get("@categories").should == {}
    end
  end

  # Some "live" tests ------------------------------------------------------------------------------

  let(:positive_arr){ File.read(File.expand_path("../data/positive",__FILE__)).split("\n") }
  let(:negative_arr){ File.read(File.expand_path("../data/negative",__FILE__)).split("\n") }

  it "should perform better (f1) with more examples" do
    results = []
    (0.1..1.0).step(0.1).each do |percent|
      subject.train_with_array :positive, positive_arr.sample(positive_arr.size*percent)
      subject.train_with_array :negative, negative_arr.sample(negative_arr.size*percent)

      results << {percent: percent}.merge(
        Bayes::Stats.error_analysis(subject, :positive, positive_arr, negative_arr)
      )

      subject.flush
    end

    Bayes::Stats.to_csv(results, name: "examples")

    results.last[:f_score].should > results.first[:f_score]
  end

  it "should perform better recall with weighting" do
    results = []
    (1..20).step(2) do |weight|
      subject.train_with_array :positive, positive_arr
      subject.train_with_array :negative, negative_arr
      subject.apply_weighting(:negative, weight)

      results << {weight: weight}.merge(
        Bayes::Stats.error_analysis(subject, :positive, positive_arr, negative_arr)
      )

      subject.flush
    end

    Bayes::Stats.to_csv(results, name: "weights")

    results.last[:recall].should > results.first[:recall]
  end
end