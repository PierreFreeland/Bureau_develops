#!/usr/bin/env ruby

require 'json'

original = JSON.parse(File.open(ARGV[0]).read)

original['taskDefinition']['containerDefinitions'].each do |container|
  container['image'] = ARGV[2]
end

puts({
  "family": ARGV[1],
  "containerDefinitions":     original['taskDefinition']['containerDefinitions'],
  "executionRoleArn":         original['taskDefinition']['executionRoleArn'],
  "networkMode":              original['taskDefinition']['networkMode'],
  "volumes":                  original['taskDefinition']['volumes'],
  "placementConstraints":     original['taskDefinition']['placementConstraints'],
  "requiresCompatibilities":  original['taskDefinition']['requiresCompatibilities']
}.to_json)
