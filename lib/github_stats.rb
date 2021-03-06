require 'github_api'
require 'dotenv'

Dotenv.load

class GithubDashboard
  
  def self.issues
    # Connect
    github = connection
    # Set up pull requests variable
    pull_requests = 0
    # Get all open issues
    issues = github.issues.list(:org => ENV['GITHUB_ORGANISATION'], :filter => 'all', :auto_pagination => true)
    issues.each do |issue|
      # If issue is a pull request, increment the pull requests variable
      if issue["pull_request"]
        pull_requests += 1
      end
    end
    # Subtract the total number of pull requests from the issues count
    open_issues = issues.count - pull_requests
    {
      :open_issues => open_issues,
      :pull_requests => pull_requests
    }
  end
  
  def self.externalpulls
    # Connect
    github = connection
    # Count up stats across all repositories
    total_pulls = 0
    merged_pulls = 0
    
    # ALL THIS CODE IS COMMENTED BECAUSE IT'S JUST TOO MEMORY-INTENSIVE.
    # WE NEED A BETTER WAY. SEE #106
    
    # github.repos.list(user: ENV['GITHUB_ORGANISATION'], :auto_pagination => true) do |repo|
    #   if repo.fork
    #     r = github.repos.find(ENV['GITHUB_ORGANISATION'], repo.name)
    #     open_pulls = github.pulls.list(r[:parent][:owner][:login], r[:parent][:name], state: 'open', :auto_pagination => true)
    #     closed_pulls = github.pulls.list(r[:parent][:owner][:login], r[:parent][:name], state: 'closed', :auto_pagination => true)
    #     # Total PRs
    #     total = 0
    #     total += open_pulls.select{|x| x[:head][:repo] && x[:head][:repo][:owner][:login] == ENV['GITHUB_ORGANISATION']}.count rescue 0
    #     total += closed_pulls.select{|x| x[:head][:repo] && x[:head][:repo][:owner][:login] == ENV['GITHUB_ORGANISATION']}.count rescue 0
    #     total_pulls += total
    #     # Merged PRs
    #     closed = closed_pulls.select{|x| x[:head][:repo] && x[:head][:repo][:owner][:login] == ENV['GITHUB_ORGANISATION'] && !x[:merged_at].nil?}.count rescue 0
    #     merged_pulls += closed
    #   end
    # end
    {
      :total_pulls => total_pulls,
      :merged_pulls => merged_pulls
    }
  end
  
  # --- Keeping this for future reference --- 
  #
  # def self.issues_graph
  #   stats = GithubStats.where(:type => "open-issues")
  #   points = []
  #   
  #   stats.each do |stat|
  #     points << { x: stat.created_at.to_i, y: stat.number }
  #   end
  #   
  #   { current: stats.all.last.number, value: stats.all.last.number, points: points, max: roundup(points.max_by{|x| x[:y]}[:y]) }
  # end
  
  def self.milestone
    # Loop through open milestones
    connection.issues.milestones.list(ENV['GITHUB_ORGANISATION'], 'shared', state: 'open', order: 'asc', sort: 'due_date').each do |milestone|
      # Do this when we first hit a milestone with a due date in the future
      if Date.parse(milestone["due_on"]) > Date.today
        @title = milestone["title"]
        @open = milestone["open_issues"]
        @closed = milestone["closed_issues"]
        @total = @open + @closed
        @value = (@closed.to_f / @total.to_f * 100).to_i rescue 0
      end
    end
  ensure
    return { min: 0, max: 100, value: @value || 0, title: @title || "error :("}
  end
  
  # def self.get_stats(type)
  #   stats = GithubStats.where(:type => type).limit(2).sort(:updated_at.desc).all    
  #   { current: stats[0].number, last: stats[1].number }
  # end
  
  def self.connection
    @@github ||= Github.new oauth_token: ENV['GITHUB_OAUTH_TOKEN']
  end
  
  # def self.roundup(num)
  #   x = Math.log10(num).floor
  #   (num/(10.0**x)).ceil * 10**x
  # end
  
end