require 'byebug'

class CraqValidator
  ERRORS = {
    not_valid: 'has an answer that is not on the list of valid answers',
    not_answered: 'was not answered',
    answered_when_completed: 'was answered even though a previous response indicated that the questions were complete'
  }

  attr_reader :questions, :answers
  attr_accessor :errors, :valid, :terminal_question

  def initialize(questions, answers)
    @questions = questions
    @answers   = answers
    @errors    = {}
    @valid     = true
    @terminal_question = {}
  end

  def valid?
    questions.each_with_index do |question, index|
      options = question[:options]
      set_terminal_question(options, index)

      if answers && answers["q#{index}".to_sym]
        not_valid(index) unless options[answers["q#{index}".to_sym]]

        check_answered_when_completed(options, index) if options[answers["q#{index}".to_sym]]
      else
        check_when_not_answered(index)
      end
    end

    valid
  end

  private
    def check_when_not_answered(index)
      return if !terminal_question.empty? && complete_if_selected_picked

      not_answered(index)
    end

    def check_answered_when_completed(options, index)
      return if terminal_question.empty?
      return if index == terminal_question[:question]

      answered_when_completed(index) if complete_if_selected_picked
    end

    def complete_if_selected_picked
      answers["q#{terminal_question[:question]}".to_sym] == terminal_question[:option]
    end

    def set_terminal_question(options, index)
      return unless terminal_question.empty?
      return unless terminal_questions(options).any?

      @terminal_question = { question: index, option: terminal_questions(options)[0] }
    end

    def terminal_questions(options)
      options.each_index.select{ |i| options[i][:complete_if_selected] == true }
    end

    def mark_as_invalid
      @valid = false if @valid
    end

    def not_answered(index)
      mark_as_invalid
      errors["q#{index}".to_sym] = ERRORS[:not_answered]
    end

    def not_valid(index)
      mark_as_invalid
      errors["q#{index}".to_sym] = ERRORS[:not_valid]
    end

    def answered_when_completed(index)
      mark_as_invalid
      errors["q#{index}".to_sym] = ERRORS[:answered_when_completed]
    end
end
