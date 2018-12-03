class LolController < ApplicationController
    require 'net/http'
    require 'json'
    require 'date'
    $API_KEY = "RGAPI-a47627cb-57b9-4a13-9ea0-472405a6655d"
    
    def home # Contains variables for the view
        uri = URI("https://euw1.api.riotgames.com/lol/match/v3/matchlists/by-account/32487406?api_key=#{$API_KEY}")
        
        
        @matchs = JSON.parse(Net::HTTP.get(uri))["matches"]
        
        @mhier = select_hier(@matchs) #Yesterday matches
        
        @total_hier_secondes = add_durations(@mhier) #adding durations of yesterday's matches
        @hier_time = Time.at(add_durations(@mhier)).utc.strftime("%H heures, %M minutes, et %S secondes") #same, converted to hours/minutes/seconds
        @hiersmic = @total_hier_secondes/3600.round(2)*9.88
    end
    
    def week 
        uri = URI("https://euw1.api.riotgames.com/lol/match/v3/matchlists/by-account/32487406?api_key=#{$API_KEY}")
        
        
        @matchs = JSON.parse(Net::HTTP.get(uri))["matches"]
        
        @mlastweek = select_lastweek(@matchs) #last eek matches
        
        @total_lastweek_secondes = @mlastweek.count * 1958
        @lastweek_time = Time.at(@total_lastweek_secondes).utc.strftime("%H heures, %M minutes") # remplacer total lastweek seconds par add durations si api key de ouf
        
        @weeksmic = @total_lastweek_secondes/3600.round(2)*9.88.round(2)
    end
    
    private
    def select_hier(liste) # return array of IDs of all games of yesterday
        return nil if liste == nil #because I don't want the page to crash but letting it run even if nil is given here
        selected_matchs = []
        liste.each {|i| #For each game of all the matchlist
            hier = (DateTime.yesterday).strftime("%m/%d") #yesterday
            jour_match = DateTime.strptime("#{i["timestamp"]}".first(10), '%s').strftime("%m/%d") #day of the match, first(10) is to avoid using milliseconds
            
            if jour_match == hier
                selected_matchs << i["gameId"] #add the id of the game to the array of IDs
            end
        }
        return selected_matchs
    end
    
    def select_lastweek(liste) # return array of IDs of all games of last week
        return nil if liste == nil
        
        selected_matchs = []
        liste.each {|i|
            now = DateTime.now #today
            lastw = now-now.wday-6 #first day of last week
            thisw = now-now.wday #last day of last week
            
            debut_sem = lastw #because before I added this : .strftime("%m/%d")
            fin_sem = thisw
            jour_match = DateTime.strptime("#{i["timestamp"]}".first(10), '%s') #day of the match
            
            if jour_match <= fin_sem && jour_match >= debut_sem #if day of the match before end of the week and after beginning of the week, ADD the ID to the array
                selected_matchs << i["gameId"]
            end
        }
        return selected_matchs
    end
    
    def add_durations(match_ids)
        #return nil if match_ids == nil
        total_seconds = 0
        match_ids.each {|i| #for each id in the array of game ID selected, 
            uri = URI("https://euw1.api.riotgames.com/lol/match/v3/matches/#{i}?api_key=#{$API_KEY}") #get the infos about that game
        
            match_infos = JSON.parse(Net::HTTP.get(uri))
            total_seconds += match_infos["gameDuration"] if match_infos["gameDuration"] != nil #add the duration to the sum of durations
            sleep(0.08) #wait a bit to bypass the time restriction of the API
        }
        return total_seconds
    end
end
