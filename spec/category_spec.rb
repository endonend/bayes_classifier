require "spec_helper"

describe Bayes::Category do
  subject{ Bayes::Category.new }

  let(:min_score){ Bayes::Category::MIN_SCORE }

  describe "#initialize" do
    it "should reset category" do
      Bayes::Category.any_instance.should_receive(:reset)
      subject
    end
  end

  describe "#train" do
    it "should split string to words and add them to words hash" do
      subject.instance_variable_set("@words", { "word1" => 5, "word4" => 4 })
      subject.instance_variable_set("@words_count", 9)

      string = double(:string)
      string.should_receive(:word_hash).and_return({ "word1" => 2, "word2" => 4, "word3" => 3 })

      subject.train string
      subject.instance_variable_get("@words").should == { "word1" => 7, "word2" => 4, "word3" => 3, "word4" => 4 }
      subject.instance_variable_get("@words_count").should == 18
    end
  end

  describe "#forget" do
    it "should split string to words and remove them from words hash" do
      subject.instance_variable_set("@words", { "word1" => 7, "word2" => 4, "word3" => 3, "word4" => 4 })
      subject.instance_variable_set("@words_count", 18)

      string = double(:string)
      string.should_receive(:word_hash).and_return({ "word1" => 2, "word2" => 4, "word3" => 3 })

      subject.forget string
      subject.instance_variable_get("@words").should == { "word1" => 5, "word4" => 4 }
      subject.instance_variable_get("@words_count").should == 9
    end
  end

  describe "#apply_weighting" do
    it "should apply weighting for top words" do
      top_words = ["top","words","ever"]

      subject.should_receive(:top_words).and_return(top_words)
      top_words.each{ |word| subject.should_receive(:apply_weighting_for).with(word, 11) }

      subject.apply_weighting(11)
    end
  end

  describe "#apply_weighting_for" do
    before :each do
      subject.instance_variable_set("@words", { "word1" => 5, "word4" => 4 })
      subject.instance_variable_set("@words_count", 9)
    end

    context "if requestsed word exists" do
      it "should multiple weight of requested word" do
        subject.apply_weighting_for "word1", 11
        subject.instance_variable_get("@words")["word1"].should == 55
        subject.instance_variable_get("@words_count").should == 59
      end
    end

    context "if requestsed word does not exist" do
      it "should do nothing" do
        subject.apply_weighting_for "word2", 11
        subject.instance_variable_get("@words")["word2"].should be_nil
        subject.instance_variable_get("@words_count").should == 9
      end
    end
  end

  describe "#top_words" do
    it "should return requested number of words with maximum weights" do
      subject.instance_variable_set "@words", { "word1" => 1, "word2" => 3, "word3" => 4, "word4" => 2 }
      subject.top_words(2).should == ["word3", "word2"]
    end
  end

  describe "#reset" do
    it "should reset words hash and words count" do
      subject.instance_variable_get("@words").should == {}
      subject.instance_variable_get("@words_count").should == 0
    end
  end

  describe "#score_for" do
    context "if words count is zero" do
      before(:each){ subject.instance_variable_set("@words_count", 0) }

      it "should return negative infinity" do
        subject.score_for("the string").should == -Float::INFINITY
      end
    end

    context "if words count is not zero" do
      before :each do
        subject.instance_variable_set "@words", { "word1" => 1, "word2" => 2, "word3" => 3, "word4" => 4 }
        subject.instance_variable_set "@words_count", 10
      end

      it "should return sum of logarithms of word weight to words count ratios" do
        subject.score_for("word1 word3 word2").should ==
          Math.log(0.1) + Math.log(0.3) + Math.log(0.2)
      end

      context "and some words does not exist" do
        it "should use weight MIN_SCORE for these words" do
          subject.score_for("word1 word5 word2 word 6").should ==
            Math.log(0.1) + Math.log(min_score/10) + Math.log(0.2) + Math.log(min_score/10)
        end
      end

      context "and there are no good words in provided string" do
        it "should return rate for a non existing word" do
          subject.score_for("q w e r t y").should == Math.log(min_score/10)
        end
      end

      context "and array of words is provided instead of string" do
        it "should work well" do
          subject.score_for(%W{word1 word3 word2}).should ==
            Math.log(0.1) + Math.log(0.3) + Math.log(0.2)
        end
      end
    end
  end

  describe "#blank?" do
    context "if words count is zero" do
      before(:each){ subject.instance_variable_set("@words_count", 0) }
      it("should return true"){ subject.blank?.should be_true }
    end

    context "if words count is zero" do
      before(:each){ subject.instance_variable_set("@words_count", 1) }
      it("should return true"){ subject.blank?.should be_false }
    end
  end
end