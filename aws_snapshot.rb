#!/usr/bin/env ruby

# This script if for displaying AWS snapshot older than a given period.
# Change threshold and owner_ids

require 'aws-sdk'
require 'aws'
require 'active_support/time'

class Snapshot
	def initialization
		@threshold = 2.months.ago
		@client = Aws::EC2::Client.new(region: 'us-west-2')
		@resp = @client.describe_snapshots({
		  owner_ids: ["XXXXXXXX"],
		  filters: [
		    {
		      name: "status",
		      values: ["completed"],
		    },
		  ],
		})
		@count = 0
	end
	def snapshot_description
		initialization
		@resp.snapshots.each do |n|
		  if name = n.tags.find { |t| t.key == 'Name' }
		    @desc = name.value
		  end
		  if n.start_time < @threshold
		  	@count += 1
		  end
		end
	end

    def snapshot_list
	  snapshot_description
		@resp.snapshots.each do |n|
			puts "#{n.snapshot_id}  #{n.start_time} #{find_snapshot_description(n)}"
		end
	end

	def counting 
	  snapshot_description
	  puts "#{@count}"
	end

	def delete_snapshot
		snapshot_description
		@resp.snapshots.each do |n|
	        snap_id = @client.delete_snapshot({
	          snapshot_id: "",
	        })
	        puts "Deleted #{n.snapshot_id}"
        end
     end

	private

	def find_snapshot_description(snapshot)
		if (name = snapshot.tags.find { |t| t.key == 'Name' })
			name.value
		end
	end

end
snap = Snapshot.new
snap.delete_snapshot