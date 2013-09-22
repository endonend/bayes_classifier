require "spec_helper"

describe String do
  describe "#word_hash" do
    subject{ "Lorem ipsum dolor lorem" }
    let(:words){ ["Lorem", "ipsum", "dolor", "lorem"] }

    before(:each){ subject.should_receive(:split_words).and_return(words) }

    it "should return hash of words and their frequencies" do
      subject.word_hash.should == { "lorem" => 2, "ipsum" => 1, "dolor" => 1 }
    end

    context "if there are stopwords and shord words" do
      let(:words){ ["Lorem", "ipsum", "dolor", "new", "last", "we", "AU"] }
      it "should exclude stopwords from result" do
        subject.word_hash.should == { "lorem" => 1, "ipsum" => 1, "dolor" => 1 }
      end
    end
  end

  describe "#split_words" do
    it "should return all words from string without spaces and punctuation" do
      "Lorem ipsum, dolor-sit. Amet:  dolorem.".split_words.should ==
        ["Lorem", "ipsum", "dolor", "sit", "Amet", "dolorem"]
    end
  end

  describe "#stopword?" do
    it "should return true if string is a stopword" do
      "and".stopword?.should be_true
    end

    it "should return false if string is not a stopword" do
      "lorem".stopword?.should be_false
    end
  end
end