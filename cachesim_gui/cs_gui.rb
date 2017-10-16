require_relative 'cs_seta_class'

Shoes.app title: "Cache Config", width: 350, height: 400 do
    background gray..white
    stack do
        caption "Set Associative Cache\n(Parameters)", align: "center", top: 30
        flow width: 300, left: 25, top: 120 do
            caption "Cache type\t", margin_bottom: 10
            list_box items: ["1. Read-only", "2. Read + Write-back", "3. Read + Write-through"], width: 170, top: -2, choose: "1. Read-only" do |i|
                $style = i.text
            end
        end
        flow width: 125, left: 85, top: 165 do
            caption "Sets\t :\t"
            $sets = edit_line width: 50, height: 24, top: 2
        end
        flow width: 125, left: 85, top: 195 do
            caption "Lines\t :\t"
            $lines = edit_line width: 50, height: 24, top: 2
        end
        flow width: 125, left: 85, top: 225 do
            caption "Words\t :\t"
            $words = edit_line width: 50, height: 24, top: 2
        end
    end
    btn0 = image "images/confirm0.png", left: 145, top: 320
    btn1 = image "images/confirm1.png", left: -64, top: 320
    button "Load", left: 145, top: 270 do
        if $sets.text.to_i > 0 && $lines.text.to_i > 0 && $words.text.to_i > 0
            btn0.left = -145
            btn1.left = 145
            $lxw = $lines.text.to_i * $words.text.to_i
            $csh = Cachesim.new($sets.text.to_i, $lines.text.to_i, $words.text.to_i)
        else
            alert "Please, ensure all the gaps has been filled."
            btn0.left = 145
            btn1.left = -145
        end
    end
    btn1.click do
        window title: "Set Associative Cache > #{$style[3, $style.size]} >  S#{$sets.text}L#{$lines.text}W#{$words.text}", width: 920, height: 620 do
            owner.close
            background white..gray
            flow do
                # SECTION ==> MAIN MEMORY, WITH RANDOM VALUES
                stack width: 155, margin: 10 do
                    caption strong(em("M. MEMORY")), stroke: orange, align: "center"
                    stack height: 560, scroll: true do
                        16.times do |i|
                            if i < 10
                                para "   #{i}\t %08x" % rand(2**16...2**32).to_s, align: "left"
                            else
                                para " #{i}\t %08x" % rand(2**16...2**32).to_s, align: "left"
                            end
                        end
                    end
                end

                # SECTION ==> CACHE VALUES
                stack width: 520, margin: 10 do
                    caption strong(em("CACHE")), stroke: orange, align: "center"
                    stack height: 560, left: 50, scroll: true do
                        button "Show", margin_left: 220 do
                            c_set = c_line = 0
                            window title: "Cache", width: 680 do
                                values = $csh.cshValues
                                stack width: 680 do
                                    for i in values
                                        tagline "SET #{c_set}", align: "center"
                                            for j in i
						  					if c_line < 10
                                            	para "   #{c_line}\t#{j}", align: "center"
											else
												para " #{c_line}\t#{j}", align: "center"
											end
                                            c_line += 1
                                        end
                                        para "\n"
                    					c_line = 0
                    					c_set += 1
                                    end
                                end
                            end
                        end
                    end
                end

                # SECTION ==> RESULTS (ACCESSES, HITS, MISSES, HIT RATE(%))
                stack width: 220, left: 695, margin_top: 10 do
                    caption strong(em("RESULTS")), stroke: darkgreen, align: "center"
                    flow do
                        stack width: 125, height: 125 do
                            para "ACCESSES\t:", align: "left"
                            para "HIT\t\t\t:", align: "left"
                            para "MISS\t\t:", align: "left"
                            para "HIT RATE\t:", align: "left"
                        end
                        stack width: 95, height: 125 do
                            $p1 = para "???", align: "center"
                            $p2 = para "???", align: "center"
                            $p3 = para "???", align: "center"
                            $p4 = para "???", align: "center"
                        end
                    end
                end

                # SECTION ==> RESET, PLAY, STEP BY STEP
                stack width: 230, height: 100, left: 685, top: 230 do
                    flow height: 24 do
                        $amnt = 1
                        s = caption "%03d" % $amnt.to_s , left: 170, top: -2
                        button "+", width: 20, height: 25, left: 150, top: 0 do
                            if $amnt < 100
                                $amnt += 1;
                                s.replace "%03d" % $amnt.to_s
                            end
                        end
                        button "-", width: 20, height: 25, left: 210, top: 0 do
                            if $amnt > 1
                                $amnt -= 1;
                                s.replace "%03d" % $amnt.to_s
                            end
                        end
                    end
                    flow height: 76 do
                        $size = $step = $amnt
                        btn_replay = image "images/replay.png", margin: 6
                        btn_play = image "images/play.png", margin: 6
                        btn_byStep = image "images/next.png", margin: 6
                        btn_play.click do
                            if $filename == nil
                                confirm "No such file loaded."
                            elsif $step < $file_size
                                if $style[0] == '1' || $style[0] == '2'
                                    $csh.letItGo($filename, $step, $file_size)
                                elsif $style[0] == '3'
                                    $csh.letItGoWthru($filename, $step, $file_size)
                                end
                                rslt = *$csh.results
                                $p1.replace rslt[0]
                                $p2.replace rslt[1]
                                $p3.replace rslt[2]
                                $p4.replace "%.1f%" % rslt[3]
                                $step = $file_size
				                confirm "All done!"
                            else
                                confirm "Sorry, all data has already been read."
                            end
                        end
                        btn_byStep.click do
                            if $filename == nil
                                confirm "No such file loaded."
                            elsif $step < $file_size
                                $step = $amnt
                                if $style[0] == '1' || $style[0] == '2'
                                    $csh.stepIt($filename, $size, $step)
                                elsif $style[0] == '3'
                                    $csh.stepItWthru($filename, $size, $step)
                                end
                                if $size > $file_size
                                    $step = $size - $file_size
                                    $size = $file_size
                                elsif $size != $file_size
                                    $size += $amnt
                                else
                                    $step = $file_size
                                end
                                rslt = *$csh.results
                                $p1.replace rslt[0]
                                $p2.replace rslt[1]
                                $p3.replace rslt[2]
                                $p4.replace "%.1f%" % rslt[3]
                                lns = *$csh.lines($filename, $size)
                                $crrt.replace lns[0]
                                $nxxt.replace lns[1]
                                $prev.replace lns[2]
                            else
                                confirm "Sorry, all data has already been read."
                            end
                        end
                        btn_replay.click do
                            $csh.reset
                            $step = $size = $amnt = 1
                            $p1.replace "???"
                            $p2.replace "???"
                            $p3.replace "???"
                            $p4.replace "???"
                            $crrt.replace "????????"
                            $nxxt.replace "????????"
                            $prev.replace "????????"
                            confirm "Cache memory successfully reset!"
                        end
                    end
                end
                # SECTION ==> PREVIOUS ONE / CURRENT / NEXT ONE
                stack width: 100, height: 172, left: 750, top: 340 do
                    stack height: 64 do
                        caption "CURRENT", stroke: green, align: "center", margin: 0
                        $crrt = para "????????", align: "center"
                    end
                    stack height: 64 do
                        caption "NEXT", stroke: blue, align: "center", margin: 0
                        $nxxt = para "????????", align: "center"
                    end
                    stack height: 64 do
                        caption "PREVIOUS", stroke: red, align: "center", margin: 0
                        $prev = para "????????", align: "center"
                    end
                end

                # SECTION ==> CHOOSE FILE
                stack width: 260, margin: 10, left: 660, top: 540 do
                    btn = image "images/App-document-find-icon.png"
                    background black, width: 180, height: 33, top: 8, left: 50
                    background white, width: 177, height: 29, top: 12, left: 53
                    c = caption "", width: 130, left: 721, top: 562, margin_left: 10, margin_top: 5, stroke: red
                    btn.click do
                        file = ask_open_file
                        for i in 0...file.size
                            if file[i] == "\\"
                                file[i] = "/"
                            end
                        end
                        $filename = file if file != nil
                        file = File.basename file
                        c.replace file, left: 721, top: 562, margin_left: 10, margin_top: 5, stroke: green
                        lns = *$csh.lines($filename, $size)
                        $crrt.replace lns[0]
                        $nxxt.replace lns[1]
                        $prev.replace lns[2]
                        $file_size = File.foreach("#{$filename}").inject(0) {|c, line| c+1}
                        if $style[0] == '2' then $csh.writeBack($filename) end
                    end
                end
            end
        end
    end
end
