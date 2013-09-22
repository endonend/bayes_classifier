require "csv"

module Bayes
  module Stats

    ### Error Analysis ====================================

    def self.error_analysis(classifier, category, positive_items, negative_items)
      true_positives = 0
      true_negatives = 0
      false_negatives = 0
      false_positives = 0

      positive_items.each do |i|
        if classifier.classify(i) == category
          true_positives += 1.0
        else
          false_negatives += 1.0
        end
      end

      negative_items.each do |i|
        if classifier.classify(i) == category
          false_positives += 1.0
        else
          true_negatives += 1.0
        end
      end

      precision = true_positives / (true_positives + false_positives)
      recall = true_positives / (true_positives + false_negatives)
      f_score = 2 * ( (precision * recall) / (precision + recall) )

      {
        true_positives: true_positives,
        true_negatives: true_negatives,
        false_negatives: false_negatives,
        false_positives: false_positives,
        precision: precision,
        recall: recall,
        f_score: f_score,
      }
    end

    def self.error_analysis_csv(classifier, filename)
      items = File.read(filename).split("\n").map {|t| t.split("||") }

      correct = 0
      incorrect = 0

      items.each do |item|
        category = classifier.classify(item.first)
        if category == item.last
          correct += 1
        else
          incorrect += 1
        end
      end

      {
        correct: correct,
        incorrect: incorrect,
        error_rate: incorrect / (incorrect + correct).to_f
      }
    end

    ### Helpers ===================================================

    def self.to_csv(results, name: "examples")
      `mkdir -p spec/reports`

      CSV.open("spec/reports/#{name}.csv", "w+") do |csv|
        csv << results.first.keys
        results.each do |r|
          csv << r.values
        end
      end
    end

  end
end