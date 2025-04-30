<script>
	import BalanceBox from "./BalanceBox.svelte";
	export let playerName = "";
	export let playerid = 0;
	export let job = "";
	export let cash = 0;
	export let bank = 0;
	export let blackmoney = 0;
	export let discordLink = "discord.gg/jaxdanger";
	export let serverName = "Cool RP";
	export let onlinePlayers = 2;
</script>

<div class="hud-container">
	<div class="top-section">
		<div class="top-content">
			<div class="discord-container">{discordLink}</div>
			<div class="server-info">
				{serverName}
			</div>
			<img src="logo.png" alt="logo" class="server-logo" />
		</div>
		<div class="online-status">{onlinePlayers} Online</div>
	</div>

	<div class="player-container">
		<div>{playerName} - {playerid}</div>
		<div>{job}</div>
	</div>

	<div class="money-container">
		<BalanceBox icon="money-icon.png" amount={cash} color="#1bd66c" />
		<BalanceBox icon="bank-icon.png" amount={bank} color="#2b83ff" />
		<BalanceBox
			icon="black-money-icon.png"
			amount={blackmoney}
			color="#ff0f0f"
		/>
	</div>
</div>

<style>
	@font-face {
		font-family: "HermanoMayor";
		src: url("/hud/web/public/HermanoMayor.ttf") format("truetype");
	}

	.hud-container {
		position: absolute;
		top: 1%;
		right: 0.6%;
		width: 450px;
		color: white;
		font-family: sans-serif;
	}

	.top-section {
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		background: rgba(50, 50, 50, 0.5);
		border-radius: 8px;
	}

	.top-content {
		display: flex;
		align-items: center;
		gap: 32px;
	}

	.discord-container,
	.server-info {
		font-size: 16px;
		font-weight: bold;
	}

	.server-info {
		display: flex;
		flex-direction: row;
		align-items: center;
		gap: 25px;
	}

	.online-status {
		font-size: 12px;
		opacity: 0.8;
		text-align: center;
		top: -15px;
		left: 40px;
		position: relative;
		color: green;
		text-shadow:
			-0.25px -0.25px 0 rgba(0, 0, 0, 0.5),
			0.25px 0.25px 0 rgba(0, 0, 0, 0.5),
			-0.25px -0.25px 0 rgba(0, 0, 0, 0.5),
			0.25px 0.75px 0 rgba(0, 0, 0, 0.5);
	}

	.player-container {
		display: flex;
		flex-direction: row;
		justify-content: center;
		gap: 125px;
		margin-top: 5px;
		background: rgba(50, 50, 50, 0.5);
		padding: 6px;
		border-radius: 8px;
		font-weight: 600;
		text-align: right;
	}

	.money-container {
		font-family: "HermanoMayor";
		position: absolute;
		right: 5px;
		transform: translateY(10%);
		display: flex;
		flex-direction: column;
		align-items: end;
		gap: 5px;
		width: 150px;
		text-shadow:
			-0.25px -0.25px 0 rgba(0, 0, 0, 0.5),
			0.25px 0.25px 0 rgba(0, 0, 0, 0.5),
			-0.25px -0.25px 0 rgba(0, 0, 0, 0.5),
			0.25px 0.75px 0 rgba(0, 0, 0, 0.5);
	}

	.server-logo {
		width: 60px;
		top: 5px;
		right: 20px;
		position: relative;
	}
</style>
