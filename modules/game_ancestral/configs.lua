COMMAND_BUYITEM = '!ancestralstore'

COINS_OPCODE = 89

storeIndex = {
	[1] = {
		id = '1',
		name = 'Aura',
		description = 'Get a cool Aura, get more Ancestral Points doing tasks!',
		image = "/images/ancestral/aura",
		imageList = '/images/ancestral/aura'
	},
	[2] = {
		id = '2',
		name = 'Wings',
		description = 'Wings are very impressive.',
		image = '/images/ancestral/wings',
		imageList = '/images/ancestral/wings'
	},
	[3] = {
		id = '3',
		name = 'Items',
		description = 'Train your character.',
		image = '/images/ancestral/item_25105_',
		imageList = '/images/ancestral/item_25105_'
	},
}

storeProducts = {
    {
		name = "Fiery Wings",
		id = '1',
		category_id = "2",
		description = 'Do you really want to buy "Fiery Wings" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Fiery Wings",
		price = 25,
		image = "/images/ancestral/offer/fiery"
    },
	{
		name = "Lullaby Wings",
		id = '2',
		category_id = "2",
		description = 'Do you really want to buy "Lullaby Wings" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Lullaby Wings",
		price = 25,
		image = "/images/ancestral/offer/lullaby"
    },
	{
		name = "Vampire Wings",
		id = '3',
		category_id = "2",
		description = 'Do you really want to buy "Vampire Wings" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Vampire Wings",
		price = 35,
		image = "/images/ancestral/offer/vampire"
    },
	{
		name = "Bark Wings",
		id = '4',
		category_id = "2",
		description = 'Do you really want to buy "Bark Wings" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Bark Wings",
		price = 45,
		image = "/images/ancestral/offer/bark"
    },
	{
		name = "Falanaar Wings",
		id = '5',
		category_id = "2",
		description = 'Do you really want to buy "Falanaar Wings" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Falanaar Wings",
		price = 60,
		image = "/images/ancestral/offer/falanaar"
    },
	{
		name = "Fireflies",
		id = '6',
		category_id = "1",
		description = 'Do you really want to buy "Fireflies Aura" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Fireflies Aura",
		price = 25,
		image = "/images/ancestral/offer/fireflies"
    },
	{
		name = "Fire Essence",
		id = '7',
		category_id = "1",
		description = 'Do you really want to buy "Fire Essence Aura" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Fire Essence",
		price = 25,
		image = "/images/ancestral/offer/flames"
    },
	{
		name = "Electric Shock",
		id = '8',
		category_id = "1",
		description = 'Do you really want to buy "Electric Shock Aura" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Blue Essence Aura",
		price = 35,
		image = "/images/ancestral/offer/electric"
    },
	{
		name = "Star Shine",
		id = '9',
		category_id = "1",
		description = 'Do you really want to buy "Star Shine Aura" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Star Shine Aura",
		price = 45,
		image = "/images/ancestral/offer/starshine"
    },
	{
		name = "Bats",
		id = '10',
		category_id = "1",
		description = 'Do you really want to buy "Bats Aura" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Bats Aura",
		price = 60,
		image = "/images/ancestral/offer/bats"
    },
	{
		name = "Exercise Sword Chest",
		id = '11',
		category_id = "3",
		description = 'Do you really want to buy "Exercise Sword Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Exercise Sword Chest",
		price = 25,
		image = "/images/ancestral/offer/item_25105_"
    },
	{
		name = "Exercise Axe Chest",
		id = '12',
		category_id = "3",
		description = 'Do you really want to buy "Exercise Axe Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Exercise Axe Chest",
		price = 25,
		image = "/images/ancestral/offer/item_25106_"
    },
	{
		name = "Exercise Club Chest",
		id = '13',
		category_id = "3",
		description = 'Do you really want to buy "Exercise Club Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Exercise Club Chest",
		price = 25,
		image = "/images/ancestral/offer/item_25107_"
    },
	{
		name = "Exercise Bow Chest",
		id = '14',
		category_id = "3",
		description = 'Do you really want to buy "Exercise Bow Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Exercise Bow Chest",
		price = 25,
		image = "/images/ancestral/offer/item_25108_"
    },
	{
		name = "Exercise Rod Chest",
		id = '15',
		category_id = "3",
		description = 'Do you really want to buy "Exercise Rod Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Exercise Rod Chest",
		price = 25,
		image = "/images/ancestral/offer/item_25109_"
    },
	{
		name = "Exercise Wand Chest",
		id = '16',
		category_id = "3",
		description = 'Do you really want to buy "Exercise Wand Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Exercise Wand Chest",
		price = 25,
		image = "/images/ancestral/offer/item_25110_"
    },
	{
		name = "Exercise Shield Chest",
		id = '17',
		category_id = "3",
		description = 'Do you really want to buy "Exercise Shield Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Exercise Shield Chest",
		price = 25,
		image = "/images/ancestral/offer/item_25111_"
    },
	{
		name = "Durable Exercise Sword Chest",
		id = '18',
		category_id = "3",
		description = 'Do you really want to buy "Durable Exercise Sword Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Durable Exercise Sword Chest",
		price = 90,
		image = "/images/ancestral/offer/item_25112_"
    },
	{
		name = "Durable Exercise Axe Chest",
		id = '19',
		category_id = "3",
		description = 'Do you really want to buy "Durable Exercise Axe Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Durable Exercise Axe Chest",
		price = 90,
		image = "/images/ancestral/offer/item_25113_"
    },
	{
		name = "Durable Exercise Club Chest",
		id = '20',
		category_id = "3",
		description = 'Do you really want to buy "Durable Exercise Club Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Durable Exercise Club Chest",
		price = 90,
		image = "/images/ancestral/offer/item_25114_"
    },
	{
		name = "Durable Exercise Bow Chest",
		id = '21',
		category_id = "3",
		description = 'Do you really want to buy "Durable Exercise Bow Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Durable Exercise Bow Chest",
		price = 90,
		image = "/images/ancestral/offer/item_25115_"
    },
	{
		name = "Durable Exercise Rod Chest",
		id = '22',
		category_id = "3",
		description = 'Do you really want to buy "Durable Exercise Rod Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Durable Exercise Rod Chest",
		price = 90,
		image = "/images/ancestral/offer/item_25116_"
    },
	{
		name = "Durable Exercise Wand Chest",
		id = '23',
		category_id = "3",
		description = 'Do you really want to buy "Durable Exercise Wand Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Durable Exercise Wand Chest",
		price = 90,
		image = "/images/ancestral/offer/item_25117_"
    },
	{
		name = "Durable Exercise Wand Chest",
		id = '24',
		category_id = "3",
		description = 'Do you really want to buy "Durable Exercise Shield Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Durable Exercise Shield Chest",
		price = 90,
		image = "/images/ancestral/offer/item_25118_"
    },
	{
		name = "Lasting Exercise Sword Chest",
		id = '25',
		category_id = "3",
		description = 'Do you really want to buy "Lasting Exercise Sword Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Lasting Exercise Sword Chest",
		price = 750,
		image = "/images/ancestral/offer/item_25119_"
    },
	{
		name = "Lasting Exercise Axe Chest",
		id = '26',
		category_id = "3",
		description = 'Do you really want to buy "Lasting Exercise Axe Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Lasting Exercise Axe Chest",
		price = 750,
		image = "/images/ancestral/offer/item_25120_"
    },
	{
		name = "Lasting Exercise Club Chest",
		id = '27',
		category_id = "3",
		description = 'Do you really want to buy "Lasting Exercise Club Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Lasting Exercise Club Chest",
		price = 750,
		image = "/images/ancestral/offer/item_25121_"
    },
	{
		name = "Lasting Exercise Bow Chest",
		id = '28',
		category_id = "3",
		description = 'Do you really want to buy "Lasting Exercise Bow Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Lasting Exercise Bow Chest",
		price = 750,
		image = "/images/ancestral/offer/item_25122_"
    },
	{
		name = "Lasting Exercise Rod Chest",
		id = '29',
		category_id = "3",
		description = 'Do you really want to buy "Lasting Exercise Rod Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Lasting Exercise Rod Chest",
		price = 750,
		image = "/images/ancestral/offer/item_25123_"
    },
	{
		name = "Lasting Exercise Wand Chest",
		id = '30',
		category_id = "3",
		description = 'Do you really want to buy "Lasting Exercise Wand Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Lasting Exercise Wand Chest",
		price = 750,
		image = "/images/ancestral/offer/item_25124_"
    },
	{
		name = "Lasting Exercise Shield Chest",
		id = '31',
		category_id = "3",
		description = 'Do you really want to buy "Lasting Exercise Shield Chest" ?\n\nNote: Once you have purchased it you will receive it instantly.',
        tooltip = "Lasting Exercise Shield Chest",
		price = 750,
		image = "/images/ancestral/offer/item_25125_"
    },
}