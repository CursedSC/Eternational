AddCSLuaFile()

dialoguesystem = dialoguesystem or {}
dialoguesystem.list = {
	["???"] = {
		["Старт"] = {["text"] = "Ошибка прогрузки.", ["variations"] = {}},
	},
}
local meta = FindMetaTable("Player")

if CLIENT then
	specialization_test = 0
end

local function isRoomRented(ply)
    local rentData = ply:GetCharacterData("tavernRent", {})
    if not rentData.expiryDate then return false end

    local currentTime = os.time()
    return currentTime < rentData.expiryDate
end

dialoguesystem.list["npc_tavern"] = {
	["Старт"] = {
		["text"] = "Приветсвую путник. Чего желаешь? Приветсвую путник. Чего желаешь? Приветсвую путник. Чего желаешь? Приветсвую путник. Чего желаешь? Приветсвую путник. Чего желаешь?",
		["variations"] = {
			{
				["name"] = "Арендовать комнату",
				["func"] = function(ply)
					netstream.Start("tavernCheckRent")
				end,
				["continue"] = "Аренда"
			},
			{
				["name"] = "Я тут новенький, расскажи что здесь можно делать.",
				["continue"] = "Информация"
			}
		}
	},
	["Информация"] = {
		["text"] = "Хорошо, что именно тебя интерисует?",
		["variations"] = {
			{
				["name"] = "Как мне получить денег?",
				["continue"] = "деньги",
			},
			{
				["name"] = "Как мне прокачать навыки?",
				["continue"] = "навыки",
			},
			{
				["name"] = "Как мне улучшить мое оружие?",
				["continue"] = "оружие",
			},
			{
				["name"] = "Как мне стать ремеслиником?",
				["continue"] = "ремесло",
			},
			{
				["name"] = "Как мне найти приключения?",
				["continue"] = "приключения",
			},
			{
				["name"] = "Спасибо",
				["continue"] = "end"
			}
		}
	},
	["деньги"] = {
		["text"] = "Деньги можно заработать множеством способов. Например, можно выполнять квесты от гильдий, убивать монстров, продавать ресурсы или же просто помогать другим игрокам. Основной заработок основываеться на продаже камней монстров.",
		["variations"] = {
			{
				["name"] = "У меня еще есть пару вопросов.",
				["continue"] = "Информация"
			},
			{
				["name"] = "Спасибо, я понял.",
				["continue"] = "end"
			}
		}
	},
	["навыки"] = {
		["text"] = "Навыки изучаються благодаря прочтению специльных книг, которые можно найти в городе или купить у других игроков. Навыки разделаються на типы оружия. Навыки не только покупаються, но и могут быть получены в процессе приключений.",
		["variations"] = {
			{
				["name"] = "У меня еще есть пару вопросов.",
				["continue"] = "Информация"
			},
			{
				["name"] = "Спасибо, я понял.",
				["continue"] = "end"
			}
		}
	},
	["ремесло"] = {
		["text"] = "Что бы стать ремеслиником, тебе нужно найти мастера нужного тебе направления и выполнить его поручения",
		["variations"] = {
			{
				["name"] = "У меня еще есть пару вопросов.",
				["continue"] = "Информация"
			},
			{
				["name"] = "Спасибо, я понял.",
				["continue"] = "end"
			}
		}
	},
	["оружие"] = {
		["text"] = "Оружие можно улучшить на точильном камне используя специальные эсенции, которые получаються с боссов подземелий.",
		["variations"] = {
			{
				["name"] = "У меня еще есть пару вопросов.",
				["continue"] = "Информация"
			},
			{
				["name"] = "Спасибо, я понял.",
				["continue"] = "end"
			}
		}
	},

	["приключения"] = {
		["text"] = "Иследуй близлежайшие окрестности и не бойся общаться с жителями города. Никогда не знаешь куда тебя приведет новое знакомство.",
		["variations"] = {
			{
				["name"] = "У меня еще есть пару вопросов.",
				["continue"] = "Информация"
			},
			{
				["name"] = "Спасибо, я понял.",
				["continue"] = "end"
			}
		}
	},
	["Аренда"] = {
		["text"] = "Хорошо, что именно тебя интерисует?",
		["variations"] = {
			{
				["name"] = "Проверить статус",
				["continue"] = "ПроверкаАренда",
			},
			{
				["name"] = "Арендовать/Продлить комнату.",
				["func"] = function(ply)
					netstream.Start("tavernRentRoom")
				end,
				["continue"] = "end"
			}
		}
	},

	["ПроверкаАренда"] = {
		["text"] = function()
			local tavernInfo = LocalPlayer():GetCharacterData("tavernRent", {})
			local isRented = isRoomRented(LocalPlayer())
			if isRented then
				local timeLeft = tavernInfo.expiryDate - os.time()
				local foramtedTime = os.date("%d дней, %H часов и %M минут", timeLeft)
				return "У вас арендована комната. Осталось времени: " .. foramtedTime .. "."
			else
				return "У вас нет арендованной комнаты."
			end
		end,
		["variations"] = {
			{
				["name"] = "Спасибо",
				["continue"] = "end",
			},
		}
	},
}

dialoguesystem.list["npc_lumberjack"] = {
	["Старт"] = {
		["text"] = "Эй, парень! Не найдется время помочь? Меня сын ждет, а работы еще куча - лес так и не заканчивается!",
		["variations"] = {
			{
				["name"] = "В чем дело?",
				["continue"] = "СутьКвеста"
			},
			{
				["name"] = "Извини, я тороплюсь.",
				["continue"] = "end"
			}
		}
	},
	["СутьКвеста"] = {
		["text"] = "Как ты слышал - я занимаюсь лесной вырубкой в нашем городишке. Помоги мне и принеси немного вырубленной древесины - я в долгу не останусь.",
		["variations"] = {
			{
				["name"] = "Конечно, тем более за награду!",
				["continue"] = "Конец"
			},
			{
				["name"] = "Я занят, мне нужно идти. Сам справишься",
				["continue"] = "end"
			}
		}
	},
	["Конец"] = {
		["text"] = "Вот и отлично! Я в тебе не сомневался, сразу увидел - сильный пацан!",
		["variations"] = {
			{
				["name"] = "Ага, сейчас все сделаю.",
				["func"] = function(ply)
					netstream.Start("dialoguesystem/setquest", "getitem", 1)
				end,
				["continue"] = "end"
			},
		}
	}
}

dialoguesystem.list["npc_waitlumberjack"] = {
	["Старт"] = {
		["text"] = "Уже закончил?",
		["variations"] = {
			{
				["name"] = "Да, смотри что принес.",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Side"]) do
						if v.name == "Помощь лесорубу" then
							questnum = k
							break
						end
					end
					netstream.Start("dialoguesystem/progressquest", "Side", questnum, "deliveryitem", "wood")
				end,
				["continue"] = "end"
			},
			{
				["name"] = "Нет, иду продолжать.",
				["continue"] = "end"
			}
		}
	},
}

dialoguesystem.list["npc_blacksmith_start"] = {
	["Старт"] = {
		["text"] = "Привет. Я немного занят, у тебя что-то срочное?",
		["variations"] = {
			{
				["name"] = "Я хотел бы обучиться твоему ремеслу.",
				["continue"] = "Конец"
			},
			{
				["name"] = "Нет, зайду попозже.",
				["continue"] = "end"
			}
		}
	},
	["Конец"] = {
		["text"] = "Ого! Очередной желающий. Слушай, я готов тебе помочь - но взамен попрошу тебя об услуге. Принеси мне немного угля и железа из ближайшей шахты - тогда мы и займемся твоим обучением.",
		["variations"] = {
			{
				["name"] = "Отлично! Сейчас буду.",
				["func"] = function(ply)
					netstream.Start("dialoguesystem/setquest", "getitem", 2)
				end,
				["continue"] = "end"
			},
			{
				["name"] = "Мне еще нужно обдумать.",
				["continue"] = "end"
			}
		}
	},
}

dialoguesystem.list["npc_blacksmith_wait"] = {
	["Старт"] = {
		["text"] = "Уже закончил?",
		["variations"] = {
			{
				["name"] = "Да, держи что есть.",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Main"]) do
						if v.name == "Жаркое дело #1" then
							questnum = k
							break
						end
					end

					netstream.Start("dialoguesystem/progressquest", "Main", questnum, "deliveryitem", "iron_ore")
					netstream.Start("dialoguesystem/progressquest", "Main", questnum, "deliveryitem", "coal")
				end,
				["continue"] = "end"
			},
			{
				["name"] = "Нет, иду продолжать.",
				["continue"] = "end"
			}
		}
	},
}

dialoguesystem.list["npc_blacksmith_secondstage"] = {
	["Старт"] = {
		["text"] = "Молодец, ты хорошо постарался. Давай займемся твоим обучением. *Кузнец передает вам записку*",
		["variations"] = {
			{
				["name"] = "*Взять записку и положить в карман*",
				["continue"] = "Конец"
			},
		}
	},
	["Конец"] = {
		["text"] = "Внимательно изучи - здесь буквально вся теория для начала. Как закончишь изучение - приходи еще раз.",
		["variations"] = {
			{
				["name"] = "Хорошо, скоро буду",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Main"]) do
						if v.name == "Жаркое дело #1" then
							questnum = k
							break
						end
					end

					netstream.Start("dialoguesystem/progressquest", "Main", questnum, "talktonpc", "nextquest")
				end,
				["continue"] = "end"
			},
		}
	},
}

dialoguesystem.list["npc_blacksmith_test"] = {
	["Старт"] = {
		["text"] = "Что, уже готов?",
		["variations"] = {
			{
				["name"] = "Да, я все изучил и готов к следующему этапу.",
				["continue"] = "Тест"
			},
			{
				["name"] = "Мне нужно еще немного времени.",
				["continue"] = "end"
			}
		}
	},
	["Тест"] = {
		["text"] = "Хорошо, тогда перейдем к тесту. Ты точно готов?",
		["variations"] = {
			{
				["name"] = "Да, я точно готов!",
				["continue"] = "Вопрос_1"
			},
			{
				["name"] = "Мне нужно еще немного времени.",
				["continue"] = "end"
			}
		}
	},
	["Вопрос_1"] = {
		["text"] = "Какие действия нужны для вытяжки?",
		["variations"] = {
			{
				["name"] = "Ударить по длинной грани",
				["continue"] = "Вопрос_2"
			},
			{
				["name"] = "Ударить по широкой грани",
				["func"] = function(ply)
					specialization_test = specialization_test + 1
				end,
				["continue"] = "Вопрос_2"
			},
			{
				["name"] = "Ударить по торцу",
				["continue"] = "Вопрос_2"
			},
		}
	},
	["Вопрос_2"] = {
		["text"] = "Что самое главное в работе кузнеца?",
		["variations"] = {
			{
				["name"] = "Безопасность",
				["func"] = function(ply)
					specialization_test = specialization_test + 1
				end,
				["continue"] = "Вопрос_3"
			},
			{
				["name"] = "Результат",
				["continue"] = "Вопрос_3"
			},
			{
				["name"] = "Заработок",
				["continue"] = "Вопрос_3"
			},
		}
	},
	["Вопрос_3"] = {
		["text"] = "Какого цвета должен быть металл при работе с ним?",
		["variations"] = {
			{
				["name"] = "Светло-оранжевого",
				["continue"] = "Вопрос_4"
			},
			{
				["name"] = "Вишнёво-красного",
				["func"] = function(ply)
					specialization_test = specialization_test + 1
				end,
				["continue"] = "Вопрос_4"
			},
			{
				["name"] = "Яблочно-мандаринового",
				["continue"] = "Вопрос_4"
			},
		}
	},
	["Вопрос_4"] = {
		["text"] = "Что нужно делать для закаливания стали после нагревания?",
		["variations"] = {
			{
				["name"] = "Оставить сталь на столе и дождаться охлаждения",
				["continue"] = "Вопрос_5"
			},
			{
				["name"] = "Начать махать сталью в разные стороны",
				["continue"] = "Вопрос_5"
			},
			{
				["name"] = "Охладить сталь, опустив в воду",
				["func"] = function(ply)
					specialization_test = specialization_test + 1
				end,
				["continue"] = "Вопрос_5"
			},
		}
	},
	["Вопрос_5"] = {
		["text"] = "Если сердце стучит в такт молоту - ...",
		["variations"] = {
			{
				["name"] = "Стоит взять перерыв",
				["func"] = function(ply)
					local ent
					for k, v in pairs(ents.GetAll()) do
						if v:GetClass() == "npc_blacksmith" then
							ent = v
							break
						end
					end
					specialization_test = 0
					timer.Simple(0.1,function ()
						dialoguesystem.MainPanel("npc_blacksmith_test", "НеПройдено", nil, ent)
					end)
				end,
				["continue"] = "end"
			},
			{
				["name"] = "Ты на верном пути",
				["func"] = function(ply)
					local ent
					for k, v in pairs(ents.GetAll()) do
						if v:GetClass() == "npc_blacksmith" then
							ent = v
							break
						end
					end
					if specialization_test == 4 then
						specialization_test = 0
						timer.Simple(0.1,function ()
							dialoguesystem.MainPanel("npc_blacksmith_test", "Пройдено", nil, ent)
						end)
					else
						specialization_test = 0
						timer.Simple(0.1,function ()
							dialoguesystem.MainPanel("npc_blacksmith_test", "НеПройдено", nil, ent)
						end)
					end
				end,
				["continue"] = "end"
			},
			{
				["name"] = "Нужно перекусить",
				["func"] = function(ply)
					specialization_test = 0
					local ent
					for k, v in pairs(ents.GetAll()) do
						if v:GetClass() == "npc_blacksmith" then
							ent = v
							break
						end
					end
					timer.Simple(0.1,function ()
						dialoguesystem.MainPanel("npc_blacksmith_test", "НеПройдено", nil, ent)
					end)
				end,
				["continue"] = "end"
			},
		}
	},
	["Пройдено"] = {
		["text"] = "Поздравляю! Ты справился, ученик. Перейдем к следующей стадии. Как будешь готов - подойди ко мне еще раз.",
		["variations"] = {
			{
				["name"] = "Хорошо, спасибо! Пойду отдохну.",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Main"]) do
						if v.name == "Жаркое дело #2" then
							questnum = k
							break
						end
					end

					netstream.Start("dialoguesystem/progressquest", "Main", questnum, "talktonpc", "test", "blacksmith_note")
				end,
				["continue"] = "end"
			},
		}
	},
	["НеПройдено"] = {
		["text"] = "Ты ответил не на все вопросы правильно. Иди перечитывай и приходи ко мне еще раз.",
		["variations"] = {
			{
				["name"] = "Хорошо, скоро буду.",
				["continue"] = "end"
			},
		}
	},
}

dialoguesystem.list["npc_blacksmith_thirdstage"] = {
	["Старт"] = {
		["text"] = "Отдохнул? Можем продолжать наше обучение?",
		["variations"] = {
			{
				["name"] = "Да, я готов к следующему этапу.",
				["continue"] = "Практика"
			},
			{
				["name"] = "Мне нужно еще немного времени.",
				["continue"] = "end"
			}
		}
	},
	["Практика"] = {
		["text"] = "Держи книгу рецептов для начального снаряжения - попробуем с тобой сковать пару клинков. Изучи ее, попытайся сделать свой первый меч и принеси его мне.",
		["variations"] = {
			{
				["name"] = "Хорошо, скоро буду.",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Main"]) do
						if v.name == "Жаркое дело #2" then
							questnum = k
							break
						end
					end

					netstream.Start("dialoguesystem/progressquest", "Main", questnum, "talktonpc", "nextquest")
				end,
				["continue"] = "end"
			},
		}
	},
}

dialoguesystem.list["npc_blacksmith_waitsword"] = {
	["Старт"] = {
		["text"] = "Уже закончил?",
		["variations"] = {
			{
				["name"] = "Вот - мой первый клинок!",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Main"]) do
						if v.name == "Жаркое дело #3" then
							questnum = k
							break
						end
					end

					netstream.Start("dialoguesystem/progressquest", "Main", questnum, "deliveryitem", "student_sword")
				end,
				["continue"] = "end"
			},
			{
				["name"] = "Нет, мне нужно еще время.",
				["continue"] = "end"
			}
		}
	},
}

dialoguesystem.list["npc_blacksmith_end"] = {
	["Старт"] = {
		["text"] = "Ну вот и все, поздравляю, боец! Ты изучил все основы работы с клинками, на этом все. Продолжай практиковаться дальше, если что - я всегда в своей кузнице. Прощай!",
		["variations"] = {
			{
				["name"] = "Спасибо вам большое, до свидания!",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Main"]) do
						if v.name == "Жаркое дело #3" then
							questnum = k
							break
						end
					end

					netstream.Start("dialoguesystem/progressquest", "Main", questnum, "talktonpc", "endquest")
				end,
				["continue"] = "end"
			},
		}
	},
}

dialoguesystem.list["npc_blacksmith_withoutquest"] = {
	["Старт"] = {
		["text"] = "Извини, я сейчас занят, приходи позже.",
		["variations"] = {
			{
				["name"] = "*Молча уйти*",
				["continue"] = "end"
			},
		}
	},
}

dialoguesystem.list["npc_alchemist_start"] = {
	["Старт"] = {
		["text"] = "Привет. Я немного занят, у тебя что-то срочное?",
		["variations"] = {
			{
				["name"] = "Я хотел бы обучиться твоему ремеслу.",
				["continue"] = "Конец"
			},
			{
				["name"] = "Нет, зайду попозже.",
				["continue"] = "end"
			}
		}
	},
	["Конец"] = {
		["text"] = "Ого! Очередной желающий. Мне срочно нужно немного трав, принеси мне их - тогда и поговорим. Держи список!",
		["variations"] = {
			{
				["name"] = "Отлично! Сейчас буду. *Взять список и пойти за травами*",
				["func"] = function(ply)
					netstream.Start("dialoguesystem/setquest", "getitem", 3)
				end,
				["continue"] = "end"
			},
			{
				["name"] = "Мне еще нужно обдумать.",
				["continue"] = "end"
			}
		}
	},
}

dialoguesystem.list["npc_alchemist_wait"] = {
	["Старт"] = {
		["text"] = "Уже закончил?",
		["variations"] = {
			{
				["name"] = "Да, держи что есть.",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Main"]) do
						if v.name == "Тайны зельевара #1" then
							questnum = k
							break
						end
					end

					netstream.Start("dialoguesystem/progressquest", "Main", questnum, "deliveryitem", "sarphan")
					netstream.Start("dialoguesystem/progressquest", "Main", questnum, "deliveryitem", "jeltic")
				end,
				["continue"] = "end"
			},
			{
				["name"] = "Нет, иду продолжать.",
				["continue"] = "end"
			}
		}
	},
}

dialoguesystem.list["npc_alchemist_secondstage"] = {
	["Старт"] = {
		["text"] = "Отлично! Ты быстро управился, так что давай все-таки перейдем к твоему обучению. Держи записку от меня - там много полезных наставлений.",
		["variations"] = {
			{
				["name"] = "*Взять записку и положить в карман*",
				["continue"] = "Конец"
			},
		}
	},
	["Конец"] = {
		["text"] = "Я буду ждать здесь, у меня еще много заказов. Как закончишь изучение - приходи.",
		["variations"] = {
			{
				["name"] = "Хорошо, скоро буду",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Main"]) do
						if v.name == "Тайны зельевара #1" then
							questnum = k
							break
						end
					end

					netstream.Start("dialoguesystem/progressquest", "Main", questnum, "talktonpc", "nextquest")
				end,
				["continue"] = "end"
			},
		}
	},
}

dialoguesystem.list["npc_alchemist_test"] = {
	["Старт"] = {
		["text"] = "Что, уже готов?",
		["variations"] = {
			{
				["name"] = "Да, я все изучил и готов к следующему этапу.",
				["continue"] = "Тест"
			},
			{
				["name"] = "Мне нужно еще немного времени.",
				["continue"] = "end"
			}
		}
	},
	["Тест"] = {
		["text"] = "Хорошо, тогда перейдем к тесту. Ты точно готов?",
		["variations"] = {
			{
				["name"] = "Да, я точно готов!",
				["continue"] = "Вопрос_1"
			},
			{
				["name"] = "Мне нужно еще немного времени.",
				["continue"] = "end"
			}
		}
	},
	["Вопрос_1"] = {
		["text"] = "Что нужно первым делом сделать алхимику-новичку?",
		["variations"] = {
			{
				["name"] = "Начать экспериментировать как можно раньше",
				["continue"] = "Вопрос_2"
			},
			{
				["name"] = "Начать изучение с базовых трав и рабочего места",
				["func"] = function(ply)
					specialization_test = specialization_test + 1
				end,
				["continue"] = "Вопрос_2"
			},
			{
				["name"] = "Изготовить первое зелье и сразу попробовать его",
				["continue"] = "Вопрос_2"
			},
		}
	},
	["Вопрос_2"] = {
		["text"] = "Перечисли главные требования к работе алхимика",
		["variations"] = {
			{
				["name"] = "Терпение, точность и чистота рабочего места",
				["func"] = function(ply)
					specialization_test = specialization_test + 1
				end,
				["continue"] = "Вопрос_3"
			},
			{
				["name"] = "Желание, талант и умение",
				["continue"] = "Вопрос_3"
			},
			{
				["name"] = "Ингредиенты, время и результат",
				["continue"] = "Вопрос_3"
			},
		}
	},
	["Вопрос_3"] = {
		["text"] = "После изготовления неизвестного зелья на ком нужно его испытать?",
		["variations"] = {
			{
				["name"] = "На людях",
				["continue"] = "Вопрос_4"
			},
			{
				["name"] = "На крысах",
				["func"] = function(ply)
					specialization_test = specialization_test + 1
				end,
				["continue"] = "Вопрос_4"
			},
			{
				["name"] = "На горшке с цветами",
				["continue"] = "Вопрос_4"
			},
		}
	},
	["Вопрос_4"] = {
		["text"] = "В чем заключается настоящая алхимия?",
		["variations"] = {
			{
				["name"] = "В таланте и желании",
				["continue"] = "Вопрос_5"
			},
			{
				["name"] = "В бездумной практике - когда-то получится",
				["continue"] = "Вопрос_5"
			},
			{
				["name"] = "В знаниях, опыте и экспериментах",
				["func"] = function(ply)
					specialization_test = specialization_test + 1
				end,
				["continue"] = "Вопрос_5"
			},
		}
	},
	["Вопрос_5"] = {
		["text"] = "Зельеварение — это не просто смешивание трав и кореньев, это - ...",
		["variations"] = {
			{
				["name"] = "Искусство превратить свой суп в философский камень.",
				["func"] = function(ply)
					local ent
					for k, v in pairs(ents.GetAll()) do
						if v:GetClass() == "npc_alchemist" then
							ent = v
							break
						end
					end
					specialization_test = 0
					timer.Simple(0.1,function ()
						dialoguesystem.MainPanel("npc_alchemist_test", "НеПройдено", nil, ent)
					end)
				end,
				["continue"] = "end"
			},
			{
				["name"] = "Танец с самой природой",
				["func"] = function(ply)
					local ent
					for k, v in pairs(ents.GetAll()) do
						if v:GetClass() == "npc_alchemist" then
							ent = v
							break
						end
					end
					if specialization_test == 4 then
						specialization_test = 0
						timer.Simple(0.1,function ()
							dialoguesystem.MainPanel("npc_alchemist_test", "Пройдено", nil, ent)
						end)
					else
						specialization_test = 0
						timer.Simple(0.1,function ()
							dialoguesystem.MainPanel("npc_alchemist_test", "НеПройдено", nil, ent)
						end)
					end
				end,
				["continue"] = "end"
			},
			{
				["name"] = "Вечный вопрос: 'А что, если это смешать?'",
				["func"] = function(ply)
					specialization_test = 0
					local ent
					for k, v in pairs(ents.GetAll()) do
						if v:GetClass() == "npc_alchemist" then
							ent = v
							break
						end
					end
					timer.Simple(0.1,function ()
						dialoguesystem.MainPanel("npc_alchemist_test", "НеПройдено", nil, ent)
					end)
				end,
				["continue"] = "end"
			},
		}
	},
	["Пройдено"] = {
		["text"] = "Поздравляю! Ты справился, ученик. Перейдем к следующей стадии. Как будешь готов - подойди ко мне еще раз.",
		["variations"] = {
			{
				["name"] = "Хорошо, спасибо! Пойду отдохну.",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Main"]) do
						if v.name == "Тайны зельевара #2" then
							questnum = k
							break
						end
					end

					netstream.Start("dialoguesystem/progressquest", "Main", questnum, "talktonpc", "test", "alchemist_note")
				end,
				["continue"] = "end"
			},
		}
	},
	["НеПройдено"] = {
		["text"] = "Ты ответил не на все вопросы правильно. Иди перечитывай и приходи ко мне еще раз.",
		["variations"] = {
			{
				["name"] = "Хорошо, скоро буду.",
				["continue"] = "end"
			},
		}
	},
}

dialoguesystem.list["npc_alchemist_thirdstage"] = {
	["Старт"] = {
		["text"] = "Отдохнул? Можем продолжать наше обучение?",
		["variations"] = {
			{
				["name"] = "Да, я готов к следующему этапу.",
				["continue"] = "Практика"
			},
			{
				["name"] = "Мне нужно еще немного времени.",
				["continue"] = "end"
			}
		}
	},
	["Практика"] = {
		["text"] = "Держи рецепт простого зелья. Попробуй изучить его и сварить свое первое зелье - я буду ждать результата здесь. Удачи!",
		["variations"] = {
			{
				["name"] = "Хорошо, скоро буду.",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Main"]) do
						if v.name == "Тайны зельевара #2" then
							questnum = k
							break
						end
					end

					netstream.Start("dialoguesystem/progressquest", "Main", questnum, "talktonpc", "nextquest")
				end,
				["continue"] = "end"
			},
		}
	},
}

dialoguesystem.list["npc_alchemist_waitpotion"] = {
	["Старт"] = {
		["text"] = "Уже закончил?",
		["variations"] = {
			{
				["name"] = "Вот - мое первое зелье!",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Main"]) do
						if v.name == "Тайны зельевара #3" then
							questnum = k
							break
						end
					end

					netstream.Start("dialoguesystem/progressquest", "Main", questnum, "deliveryitem", "student_potion")
				end,
				["continue"] = "end"
			},
			{
				["name"] = "Нет, мне нужно еще время.",
				["continue"] = "end"
			}
		}
	},
}

dialoguesystem.list["npc_alchemist_end"] = {
	["Старт"] = {
		["text"] = "На удивление, хоть это и простое зелье, но ты выполнил работу на все сто! Отлично, я могу тебя поздравить - ты уже изучил основы алхимии. На этом я могу лишь пожелать тебе удачи, дальше ты сам.",
		["variations"] = {
			{
				["name"] = "Спасибо вам большое, до свидания!",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Main"]) do
						if v.name == "Тайны зельевара #3" then
							questnum = k
							break
						end
					end

					netstream.Start("dialoguesystem/progressquest", "Main", questnum, "talktonpc", "endquest")
				end,
				["continue"] = "end"
			},
		}
	},
}

dialoguesystem.list["npc_alchemist_withoutquest"] = {
	["Старт"] = {
		["text"] = "Извини, я сейчас занят, приходи позже.",
		["variations"] = {
			{
				["name"] = "*Молча уйти*",
				["continue"] = "end"
			},
		}
	},
}

dialoguesystem.list["npc_getitem"] = {
	["Старт"] = {
		["text"] = "Привет, тебе что-то нужно?",
		["variations"] = {
			{
				["name"] = "Нет, просто прогуливаюсь",
				["continue"] = "end"
			},
		}
	},
}

dialoguesystem.list["npc_waitgetitem"] = {
	["Старт"] = {
		["text"] = "Привет. Принес что-то?",
		["variations"] = {
			{
				["name"] = "Да, держи добытые ресурсы.",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Side"]) do
						if v.name == "Добыть и передать скупщику" then
							questnum = k
							break
						end
					end

					netstream.Start("dialoguesystem/progressquest", "Side", questnum, "deliveryitem")
				end,
				["continue"] = "end"
			},
			{
				["name"] = "Нет, иду продолжать.",
				["continue"] = "end"
			}
		}
	},
}

dialoguesystem.list["npc_waitpoints"] = {
	["Старт"] = {
		["text"] = "Привет. Как разведка?",
		["variations"] = {
			{
				["name"] = "*Доложить о выполненной работе*",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Side"]) do
						if v.name == "Проверить заданые координаты" and v.tasks[1].iscompleted then
							questnum = k
							break
						end
					end

					netstream.Start("dialoguesystem/progressquest", "Side", questnum, "talktonpc")
				end,
				["continue"] = "end"
			},
			{
				["name"] = "Нет, иду продолжать.",
				["continue"] = "end"
			}
		}
	},
}

dialoguesystem.list["npc_waithunt"] = {
	["Старт"] = {
		["text"] = "Привет. Что там с заказом?",
		["variations"] = {
			{
				["name"] = "*Доложить о выполненной работе*",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Side"]) do
						if v.codename == "hunt" and v.tasks[1].iscompleted then
							questnum = k
							break
						end
					end

					netstream.Start("dialoguesystem/progressquest", "Side", questnum, "talktonpc")
				end,
				["continue"] = "end"
			},
			{
				["name"] = "Нет, иду продолжать.",
				["continue"] = "end"
			}
		}
	},
}

dialoguesystem.list["npc_oldman"] = {
	["Старт"] = {
		["text"] = "Э-э, ты еще кто? Чего приперся, решил тоже посмеяться над моими бреднями? Я посмотрю на вас, когда эти твари будут убивать ваших родных, а вы даже ничего и не сделали!",
		["variations"] = {
			{
				["name"] = "Старик, что ты несешь? Успокойся и объясни без криков.",
				["continue"] = "Квест"
			},
			{
				["name"] = "Успокойся, старикан. Не к тебе пришел.",
				["continue"] = "end"
			}
		}
	},
	["Квест"] = {
		["text"] = "Я же уже кучу раз сказал! Эти лесные твари убьют вас, если ничего не сделать! Мне никто не верит и никто даже не хочет выслушать меня - я лично видел, как они тащили труп моего сына к какому-то ритуалу!",
		["variations"] = {
			{
				["name"] = "Ты точно в порядке? Я готов тебе помочь",
				["continue"] = "Конец"
			},
			{
				["name"] = "Хах, никто в эту чушь не поверит. Давай, удачи.",
				["continue"] = "end"
			}
		}
	},
	["Конец"] = {
		["text"] = "Готов помочь? Правда? Хорошо, вот в чем дело. На озере возле местной лесорубки мы рыбачили с сыном, решили немного прогуляться и почуяв странный запах.. наткнулись на этих тварей! Проведай местность возле озера, ты точно их найдешь!",
		["variations"] = {
			{
				["name"] = "Хорошо, я посмотрю что там. Надеюсь ты не сошел с ума, жди здесь.",
				["func"] = function(ply)
					netstream.Start("dialoguesystem/setquest", "helpoldman")
				end,
				["continue"] = "end"
			},
		}
	},
}

dialoguesystem.list["npc_oldmanwait"] = {
	["Старт"] = {
		["text"] = "Ухх.. ты нашел тех чудовищ, о которых я говорил?",
		["variations"] = {
			{
				["name"] = "*Доложить о выполненной работе*",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Main"]) do
						if v.codename == "helpoldman" and v.tasks[2].iscompleted then
							questnum = k
							break
						end
					end

					netstream.Start("dialoguesystem/progressquest", "Main", questnum, "talktonpc", "endquest")
				end,
				["continue"] = "end"
			},
			{
				["name"] = "Нет, еще ищу.",
				["continue"] = "end"
			}
		}
	},
}

dialoguesystem.list["npc_oldmannotwait"] = {
	["Старт"] = {
		["text"] = "Спасибо тебе огромное за веру в мои слова! Я уже дал тебе все что мог, прости, больше нечего.",
		["variations"] = {
			{
				["name"] = "*Молча уйти*",
				["continue"] = "end"
			},
		}
	},
}

dialoguesystem.list["questitem_totem"] = {
	["Старт"] = {
		["text"] = "Вы видите тотем, от которого исходит неприятный запах. Что с ним сделать?",
		["variations"] = {
			{
				["name"] = "Попытаться разломать",
				["func"] = function(ply)
					local questnum
					for k, v in pairs(meta.Quests["Main"]) do
						if v.codename == "helpoldman" then
							questnum = k
							break
						end
					end

					netstream.Start("dialoguesystem/progressquest", "Main", questnum, "talktonpc", "questitemuse")
				end,
				["continue"] = "end"
			},
			{
				["name"] = "Пройти мимо",
				["continue"] = "end"
			},
		}
	},
}
