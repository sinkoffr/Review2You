require 'httparty'
require 'nokogiri'
require 'open-uri'

class LendingTreeReview

	def initialize(lender_type, lender_name, lender_identifier)
		@url = "https://www.lendingtree.com/reviews/#{lender_type}/#{lender_name}/#{lender_identifier}"		
	end

	def get_reviews(url)
		begin
			if valid_url(url) ===["200", "OK"]
				@unparsed_data = HTTParty.get(url)
			end
			if @unparsed_data.response.body.nil? || @unparsed_data.response.body.empty?
				return
			else
				@parsed_reviews = Nokogiri::HTML(@unparsed_data)
			end
		rescue StandardError => error
			raise error
		end
	end

	def reviews
		page = 1
		get_reviews(@url)
		reviews = []
		begin
			review_listings = @parsed_reviews.css('div.mainReviews')
			if review_listings.length > 0
				per_page = review_listings.count 
				total_reviews = @parsed_reviews.css('b.hidden-xs').text.split(" ")[0].to_i
				last_page = (total_reviews.to_f / per_page.to_f).round
				while page <= last_page
					paginated_url = @url + "?sort=cmV2aWV3c3VibWl0dGVkX2Rlc2M=&pid=#{page}"
					get_reviews(paginated_url)
					paginated_review_listings = @parsed_reviews.css('div.mainReviews')
					paginated_review_listings.each do |review_listing|
						review = {
							title: review_listing.css('p.reviewTitle').text,
							content: review_listing.css('p.reviewText').text,
							author: review_listing.css('p.consumerName').text.split(' ')[0],
							star_rating: review_listing.css('div.numRec').text.gsub(/[()]/, '(' => '', ')' => ' '),
							review_date: review_listing.css('p.consumerReviewDate').text,
							recommended_by_reviewer: recommended(review_listing.css('div.lenderRec').text)
						}
						reviews << review
					end
					page += 1
				end
			end
		rescue StandardError => error
			raise error
		end
		return {
			reviews: reviews
		}
	end

	private

	def recommended(data)
		if data === "Recommended"
			return "Yes"
		else
			return "No"
		end
	end

	def valid_url(url)
		open(url).status
	end

	review = LendingTreeReview.new("personal", "first-midwest-bank", 52903183)
	data = review.reviews
end