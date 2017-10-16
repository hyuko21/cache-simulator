class Cachesim
    def initialize(n_sets, n_lines, n_words)
        @cachex = []
        @hit = @miss = 0.0
        @n_sets = n_sets
        @n_words = n_words
        @lxw = n_lines * @n_words

        for i in 0...@n_sets
            @cachex[i] = []
        	for j in 0...@lxw
        		@cachex[i][j] = nil
        	end
        end
    end

    def LookForValue(array, set, slots, value)
		for j in 0...slots
			if array[set][j] == nil
				return 0, j
			elsif array[set][j][0, value.size] == value
				return 1, j
			end
		end
        return false
    end

    def LookForNil(array, set, start, slots)
        for j in start...slots
            if array[set][j] == nil
                return 0, j
            end
        end
        return false
    end

    def RearrangeValues(set, slots)
		for j in 0...(slots - 1)
			@cachex[set][j] = @cachex[set][j+1]
		end
    end

    def QuickRearrange(set, start, range)
 		for j in start...(range - 1)
			@cachex[set][j] = @cachex[set][j+1]
		end
    end

    def writeBack(filename)
        j = count = 0
        fw = File.open("#{filename}")
        fw.each do |line|
            if line[0] == '0' then value = line[2, line.size - 2].to_i(16) else next end
            bin = "%032b" % value.to_s
            offset = Math::log(@n_words * 4, 2).to_i
            set = Math::log(@n_sets, 2).to_i
            offset = bin[32 - offset, offset]
            set = bin[32 - (offset.size + set), set]
            index = set.to_i(2)
            finder = *LookForNil(@cachex, index, 0, @lxw)
            if finder[0] != false
                @cachex[index][finder[1]] = bin
            else
                RearrangeValues(index, @lxw)
                @cachex[index][@lxw-1] = bin
            end
        end
    end

    def lines(filename, step)
        prev = File.open("#{filename}").each_line.take(step-1).last if step > 1
        crrt = File.open("#{filename}").each_line.take(step).last
        nxxt = File.open("#{filename}").each_line.take(step+1).last
        return crrt, nxxt, prev
    end

    def stepIt(filename, size, step)
        lines = File.open("#{filename}").each_line.take(size).last(step)
        lines.each do |line|
            if line[0] == '2' then value = line[2, line.size - 2].to_i(16) else return 0 end
            bin = "%032b" % value.to_s
            offset = Math::log(@n_words * 4, 2).to_i
            set = Math::log(@n_sets, 2).to_i
            offset = bin[32 - offset, offset]
            set = bin[32 - (offset.size + set), set]
            tag = bin[0, 32 - (offset.size + set.size)]
            index = set.to_i(2)
            finder = *LookForValue(@cachex, index, @lxw, tag)
            if finder[0] != false
                if finder[0] == 1
                    @hit += 1.0
                    start = finder[1]
	      			if @cachex[index][@lxw-1] == nil
                    	finder = *LookForNil(@cachex, index, start, @lxw)
                        range = finder[1]
                        QuickRearrange(index, start, range)
                        @cachex[index][range-1] = bin
                    else
			   			QuickRearrange(index, start, @lxw)
                        @cachex[index][@lxw-1] = bin
                    end
                else
                    @miss += 1.0
                    @cachex[index][finder[1]] = bin
                end
            else
                @miss += 1.0
                RearrangeValues(index, @lxw)
                @cachex[index][@lxw-1] = bin
            end
        end
    end

    def stepItWthru(filename, size, step)
        lines = File.open("#{filename}").each_line.take(size).last(step)
        lines.each do |line|
            if line[0] != '0' then value = line[2, line.size - 2].to_i(16) else return 0 end
            bin = "%032b" % value.to_s
            offset = Math::log(@n_words * 4, 2).to_i
            set = Math::log(@n_sets, 2).to_i
            offset = bin[32 - offset, offset]
            set = bin[32 - (offset.size + set), set]
            tag = bin[0, 32 - (offset.size + set.size)]
            index = set.to_i(2)
            finder = *LookForValue(@cachex, index, @lxw, tag)
            if finder[0] != false
                if finder[0] == 1
                    @hit += 1.0
                    start = finder[1]
	      			if @cachex[index][@lxw-1] == nil
                    	finder = *LookForNil(@cachex, index, start, @lxw)
                        range = finder[1]
                        QuickRearrange(index, start, range)
                        @cachex[index][range-1] = bin
                    else
			   			QuickRearrange(index, start, @lxw)
                        @cachex[index][@lxw-1] = bin
                    end
                else
                    @miss += 1.0
                    @cachex[index][finder[1]] = bin
                end
            else
                @miss += 1.0
                RearrangeValues(index, @lxw)
                @cachex[index][@lxw-1] = bin
            end
        end
    end

    def letItGo(filename, min, max)
        fr = File.open("#{filename}").each_line.to_a.last(max - min)
        fr.each do |line|
            if line[0] == '2' then value = line[2, line.size - 2].to_i(16) else next end
            bin = "%032b" % value.to_s
            offset = Math::log(@n_words * 4, 2).to_i
            set = Math::log(@n_sets, 2).to_i
            offset = bin[32 - offset, offset]
            set = bin[32 - (offset.size + set), set]
            tag = bin[0, 32 - (offset.size + set.size)]
            index = set.to_i(2)
            finder = *LookForValue(@cachex, index, @lxw, tag)
            if finder[0] != false
                if finder[0] == 1
                    @hit += 1.0
                    start = finder[1]
	      			if @cachex[index][@lxw-1] == nil
                    	finder = *LookForNil(@cachex, index, start, @lxw)
                        range = finder[1]
                        QuickRearrange(index, start, range)
                        @cachex[index][range-1] = bin
                    else
			   			QuickRearrange(index, start, @lxw)
                        @cachex[index][@lxw-1] = bin
                    end
                else
                    @miss += 1.0
                    @cachex[index][finder[1]] = bin
                end
            else
                @miss += 1.0
                RearrangeValues(index, @lxw)
                @cachex[index][@lxw-1] = bin
            end
        end
    end

    def letItGoWthru(filename, min, max)
        fr = File.open("#{filename}").each_line.to_a.last(max - min)
        fr.each do |line|
            if line[0] != '0' then value = line[2, line.size - 2].to_i(16) else next end
            bin = "%032b" % value.to_s
            offset = Math::log(@n_words * 4, 2).to_i
            set = Math::log(@n_sets, 2).to_i
            offset = bin[32 - offset, offset]
            set = bin[32 - (offset.size + set), set]
            tag = bin[0, 32 - (offset.size + set.size)]
            index = set.to_i(2)
            finder = *LookForValue(@cachex, index, @lxw, tag)
            if finder[0] != false
                if finder[0] == 1
                    @hit += 1.0
                    start = finder[1]
	      			if @cachex[index][@lxw-1] == nil
                    	finder = *LookForNil(@cachex, index, start, @lxw)
                        range = finder[1]
                        QuickRearrange(index, start, range)
                        @cachex[index][range-1] = bin
                    else
			   			QuickRearrange(index, start, @lxw)
                        @cachex[index][@lxw-1] = bin
                    end
                else
                    @miss += 1.0
                    @cachex[index][finder[1]] = bin
                end
            else
                @miss += 1.0
                RearrangeValues(index, @lxw)
                @cachex[index][@lxw-1] = bin
            end
        end
    end

    def cshValues
        return @cachex
    end

    def reset
        @cachex = []
        @hit = @miss = 0.0

        for i in 0...@n_sets
            @cachex[i] = []
        	for j in 0...@lxw
        		@cachex[i][j] = nil
        	end
        end
    end

    def results
        accs = @hit + @miss
        hit_rate = @hit / accs * 100.0
        return accs.to_i, @hit.to_i, @miss.to_i, hit_rate
    end
end
