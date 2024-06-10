import logging
import os
from dotenv import load_dotenv
from telegram import Update
from telegram.ext import Application, CommandHandler, ContextTypes

load_dotenv(".envfile")  # Load environment variables from .envfile

logging.basicConfig(format="%(asctime)s - %(name)s - %(levelname)s - %(message)s", level=logging.INFO)
logger = logging.getLogger(__name__)

async def start_callback(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Displays info on how to use the bot."""
    logged_in = os.getenv("LOGGED_IN")

    if logged_in:
        msg = (
            "Use /select_plan to list the available Bots.\n"
            "Use /withdrawal to initiate a withdrawal.\n"
            "Use /open_ticket to open a support ticket."
        )
    else:
        msg = (
            "Use /create_account to create a new account.\n"
            "Use /login to log in to your account."
        )
    await update.message.reply_text(msg)

async def select_plan_callback(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Lists the available checkouts for selecting a plan and provides the description and URL."""
    # Fetch the available checkouts from your system or API
    checkouts = [
        {
            "name": "Hudson Rivers Starter Trading Bot",
            "description": "The Hudson Rivers trading bot provides integrated solutions for making trades smooth for you. This bot makes it possible to get returns of up to 1.475% interest daily",
            "url": "https://cutt.ly/4ww4KvAj"
        },
        {
            "name": "Hudson Rivers Advanced Trading Bot",
            "description": "The Hudson Rivers advanced trading bot provides integrated solutions for making trades smooth for you. This bot makes it possible to get returns of up to 2.55% interest daily from potential market",
            "url": "https://cutt.ly/qww4Vqna"
        },
        {
            "name": "Hudson Rivers Professional Trading Bot",
            "description": "The Hudson Rivers professional trading bot provides integrated solutions for making trades smooth for you. This bot makes it possible to get returns of up to 6.575% interest weekly from the market",
            "url": "https://cutt.ly/Bww47YgQ"
        }
    ]

    # Generate a formatted list of checkouts with their descriptions and URLs
    checkout_list = "\n\n".join([f"{i + 1}. {c['name']}:\n{c['description']}\nURL: {c['url']}\n" for i, c in enumerate(checkouts)])

    # Send the checkout list to the user
    await update.message.reply_text(f"Available checkouts:\n\n{checkout_list}")

async def withdrawal_callback(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Initiates a withdrawal by asking for wallet and verification pin."""
    await update.message.reply_text("Please input your Bitcoin wallet.")

async def open_ticket_callback(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Opens a support ticket by sending a message to the admin."""
    admin_chat_id = os.getenv("6008082458")
    await context.bot.send_message(admin_chat_id, "Please open a support ticket @Dougborden01.")

def main() -> None:
    """Run the bot."""
    bot_token = os.getenv("5977373456:AAH8gz-xbuWGRwJ8C2I3zvkp0IQ48Gzy6fM")  # Replace with your bot API token
    application = Application.builder().token(bot_token).build()

    application.add_handler(CommandHandler("start", start_callback))
    application.add_handler(CommandHandler("select_plan", select_plan_callback))
    application.add_handler(CommandHandler("withdrawal", withdrawal_callback))
    application.add_handler(CommandHandler("open_ticket", open_ticket_callback))

    application.run_polling()

if __name__ == "__main__":
    main()
