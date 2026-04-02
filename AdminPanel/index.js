const { Client, GatewayIntentBits, REST, Routes, SlashCommandBuilder } = require('discord.js')
const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args))

const BOT_TOKEN = "MTMwNzUwODExNTQzNjA4MTE5Mw.GPvN1f.nv-3OjgprSD944xBsC-enMqHsyhJ0lwuQ7RxeI"
const CLIENT_ID = "1307508115436081193"
const BIN_ID = "69cdc2a636566621a86f5042"
const BIN_KEY = "$2a$10$N0ADRm/AhB/TY4ZUsWZW5O.AgMTTUoqn5cFEDh9R2dCAH.q5Tir1S"
const BIN_URL = `https://api.jsonbin.io/v3/b/${BIN_ID}`

async function updateBin(data) {
    await fetch(BIN_URL, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json',
            'X-Master-Key': BIN_KEY
        },
        body: JSON.stringify(data)
    })
}

async function getBin() {
    const res = await fetch(`${BIN_URL}/latest`, {
        headers: { 'X-Master-Key': BIN_KEY }
    })
    const json = await res.json()
    return json.record
}

const commands = [
    new SlashCommandBuilder()
        .setName('settings')
        .setDescription('Controla qualquer setting do script')
        .addStringOption(opt => opt
            .setName('tab')
            .setDescription('Ex: FarmTab, GamemodesTab, PotionsTab...')
            .setRequired(true))
        .addStringOption(opt => opt
            .setName('key')
            .setDescription('Ex: AutoFarm, AutoFarmEasterBoss...')
            .setRequired(true))
        .addStringOption(opt => opt
            .setName('value')
            .setDescription('Ex: true, false, 0.5...')
            .setRequired(true)),

    new SlashCommandBuilder()
        .setName('status')
        .setDescription('Mostra o estado atual do script'),

    new SlashCommandBuilder()
        .setName('reset')
        .setDescription('Reseta todas as settings para false/off'),
]

const client = new Client({ intents: [GatewayIntentBits.Guilds] })

client.on('interactionCreate', async interaction => {
    if (!interaction.isChatInputCommand()) return

    await interaction.deferReply() // responde imediatamente, evita timeout

    if (interaction.commandName === 'settings') {
        const tab = interaction.options.getString('tab')
        const key = interaction.options.getString('key')
        const rawValue = interaction.options.getString('value')

        let value
        if (rawValue === 'true') value = true
        else if (rawValue === 'false') value = false
        else if (!isNaN(rawValue)) value = Number(rawValue)
        else value = rawValue

        const state = await getBin()

        if (!state[tab]) {
            return await interaction.editReply(`❌ Tab **${tab}** não encontrada.`)
        }

        state[tab][key] = value
        await updateBin(state)
        await interaction.editReply(`✅ **${tab}.${key}** = **${value}**`)
    }

    if (interaction.commandName === 'status') {
        const state = await getBin()

        const lines = []
        for (const [tab, settings] of Object.entries(state)) {
            lines.push(`\n**${tab}**`)
            for (const [key, value] of Object.entries(settings)) {
                if (typeof value === 'boolean') {
                    lines.push(`- ${key}: **${value ? '✅' : '❌'}**`)
                } else {
                    lines.push(`- ${key}: **${value}**`)
                }
            }
        }

        const message = lines.join('\n')
        await interaction.editReply(message.length <= 2000 ? message : message.slice(0, 2000))
    }

    if (interaction.commandName === 'reset') {
        const state = await getBin()

        for (const tab of Object.values(state)) {
            for (const key of Object.keys(tab)) {
                if (typeof tab[key] === 'boolean') tab[key] = false
            }
        }

        await updateBin(state)
        await interaction.editReply(`🔄 Todas as settings resetadas!`)
    }
})
client.once('ready', async () => {
    const rest = new REST().setToken(BOT_TOKEN)
    await rest.put(Routes.applicationCommands(CLIENT_ID), {
        body: commands.map(c => c.toJSON())
    })
    console.log(`Bot online: ${client.user.tag}`)
})

client.login(BOT_TOKEN)