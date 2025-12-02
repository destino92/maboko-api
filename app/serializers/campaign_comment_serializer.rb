# app/serializers/campaign_comment_serializer.rb
class CampaignCommentSerializer
  include Typelizer::DSL

  attr_reader :comment

  def initialize(comment)
    @comment = comment
  end

  typelize :integer
  def id
    comment.id
  end

  typelize :string
  def content
    comment.content
  end

  typelize :string
  def comment_type
    comment.comment_type
  end

  typelize :string
  def created_at
    comment.created_at.iso8601
  end

  def user
    UserSerializer.new(comment.user).as_json
  end

  def as_json
    {
      id: id,
      content: content,
      comment_type: comment_type,
      created_at: created_at,
      user: user
    }
  end
end