<script>
	export let icon = "";
	export let amount = 0;
	export let color = "#ffffff";

	$: styleColor = `colro ${color};`; // Reactive statement for styling
</script>

<div class="balance-box" style={styleColor}>
	<img src={icon} class="icon" alt="icon" />
	<span class="dollar-sign">$</span>
	<span>{amount.toLocaleString()}</span>
</div>

<style>
	.balance-box {
		display: flex;
		align-items: center;
		background: rgba(31, 31, 31, 0.5);
		padding: 6px 16px;
		border-radius: 5px;
		font-size: 18px;
		font-weight: 400;
	}

	.icon {
		width: 28px;
		margin-right: 8px;
	}

	.dollar-sign {
		color: white;
		padding: 2px;
	}
</style>
