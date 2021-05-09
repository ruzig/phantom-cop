class PullRequestSelector
  attr_reader :pr_response

  def initialize(pr_response)
    @pr_response = pr_response
  end

  def pr_attrs_for_fetcher
    {
      node_id: pr_response[:node_id],
      html_url: pr_response[:html_url],
      number: pr_response[:number],
      state: pr_response[:state],
      title: pr_response[:title],
      github_created_at: pr_response[:created_at],
      github_updated_at: pr_response[:updated_at],
      closed_at: pr_response[:closed_at],
      merged_at: pr_response[:merged_at],
      base_ref: pr_response[:base][:ref],
      head_ref: pr_response[:head][:ref]
    }
  end
end
