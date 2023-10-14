# # Check if the latest record is from today, save latest record
# # Call the API
# # understand the response, and either sleep, de activate company, or unpack records
# # when unpacking, avoid processing entries we already have





#     if result["Error Message"]
#       p "error message for #{ticker}"
#       return
#     end
#     if result["Error Message"]
#       p "error message for #{ticker}"
#       return
#     end

#     if result['Note']
#       puts "sleeping for 3 seconds"
#       sleep 3
#       call_alpha_api(ticker)
#     end
#     # if result != nil && result["Time Series (Daily)"] != nil && ticker != nil
#     #  unpack_records(result, ticker)
#     # end
#     unless result['Note'].nil?
#       unpack_records(result, ticker)
#     end

Company.find_by(ticker: 'AG').get_records
