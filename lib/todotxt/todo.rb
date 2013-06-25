require "todotxt/regex"

module Todotxt
  class Todo

    attr_accessor :text
    attr_accessor :line
    attr_accessor :priority
    attr_accessor :projects
    attr_accessor :contexts
    attr_accessor :done
    attr_accessor :created_date
    attr_accessor :completed_date

    def initialize text, line=nil
      @line = line

      create_from_text text
    end

    def create_from_text text
      @text = text
      @priority = text.scan(PRIORITY_REGEX).flatten.first || nil
      @projects = text.scan(PROJECT_REGEX).flatten.uniq   || []
      @contexts = text.scan(CONTEXT_REGEX).flatten.uniq   || []
      @done = !text.scan(DONE_REGEX).empty?
    end

    def set_created_date
      unless created_date
        @text = [current_date, text].join(' ')
      end
    end

    def set_completed_date
      unless completed_date
        @text = "#{current_date} #{created_date} #{text.gsub(/(\d{4}-\d{2}-\d{2})\s/,'')}".strip
      end
    end


    def due
      date = Chronic.parse(text.scan(DATE_REGEX).flatten[2])
      date.nil? ? nil : date.to_date
    end

    def current_date
      Time.now.strftime("%Y-%m-%d")
    end

    def created_date
      if done
        text.match(/^x\s(\d{4}-\d{2}-\d{2}\s)(\d{4}-\d{2}-\d{2}\s)?/).to_a.compact.last.strip
      else
        m = text.match(/^(\(.\))?\s?(\d{4}-\d{2}-\d{2})\s/)
        m.to_a.compact.last.strip if m
      end
    end

    def completed_date
      m = text.match(/^x\s(\d{4}-\d{2}-\d{2}\s)(\d{4}-\d{2}-\d{2}\s)?/)
      m[1].strip if m && m[1]
    end


 
    def do
      unless done
        set_completed_date
        @text = "x #{text}".strip
        @done = true
      end
    end

    def undo
      if done
        @text = text.sub(DONE_REGEX, "").strip
        @done = false
      end
    end

    def prioritize new_priority=nil, opts={}
      if new_priority && !new_priority.match(/^[A-Z]$/i)
        return
      end

      if new_priority
        new_priority = new_priority.upcase
      end

      priority_string = new_priority ? "(#{new_priority}) " : ""

      if priority && !opts[:force]
        @text.gsub! PRIORITY_REGEX, priority_string
      else
        @text = "#{priority_string}#{text}".strip
      end

      @priority = new_priority
    end

    def append appended_text=""
      @text << " " << appended_text
    end

    def prepend prepended_text=""
      @text = "#{prepended_text} #{text.gsub(PRIORITY_REGEX, '')}"
      prioritize priority, :force => true
    end

    def replace text
      create_from_text text
    end

    def to_s
      text.clone
    end

    def <=> b
      if priority.nil? && b.priority.nil?
        return line <=> b.line
      end

      return 1 if priority.nil?
      return -1 if b.priority.nil?

      return priority <=> b.priority
    end

  end
end
