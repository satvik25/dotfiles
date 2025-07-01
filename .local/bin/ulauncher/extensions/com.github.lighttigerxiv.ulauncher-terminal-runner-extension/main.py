#!/usr/bin/env python3
import os
import subprocess
import logging

from ulauncher.api.client.Extension import Extension
from ulauncher.api.client.EventListener import EventListener
from ulauncher.api.shared.event import KeywordQueryEvent, ItemEnterEvent
from ulauncher.api.shared.item.ExtensionResultItem import ExtensionResultItem
from ulauncher.api.shared.action.RenderResultListAction import RenderResultListAction
from ulauncher.api.shared.action.ExtensionCustomAction import ExtensionCustomAction
from ulauncher.api.shared.action.HideWindowAction import HideWindowAction

# Enable debug logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)


class TerminalRunner(Extension):
    def __init__(self):
        super().__init__()
        logger.debug("Initializing TerminalRunner")
        self.subscribe(KeywordQueryEvent, QueryListener())
        self.subscribe(ItemEnterEvent, CommandListener())


class QueryListener(EventListener):
    def on_event(self, event, extension):
        query = event.get_argument() or ""
        logger.debug("QueryListener received: %r", query)
        return RenderResultListAction([
            ExtensionResultItem(
                icon="images/icon.png",
                name=f"Run: {query}",
                on_enter=ExtensionCustomAction({"command": query}),
            )
        ])


class CommandListener(EventListener):
    def on_event(self, event, extension):
        cmd = event.get_data().get("command", "").strip()
        logger.debug("CommandListener got command: %r", cmd)

        if not cmd:
            return HideWindowAction()

        home = os.path.expanduser("~")
        # log_path = os.path.join(home, "ulauncher.log")
        zshrc = os.path.join(home, ".zshrc")
        shell = os.environ.get("SHELL", "/usr/bin/zsh")

        # Build a shell payload that:
        # 1) sources ~/.zshrc (so your functions are loaded)
        # 2) runs the command in background
        # 3) disowns the job so it survives the shell exit
        #
        # The redirection to ulauncher.log has been commented out.
        payload = (
            f"source {zshrc} && "
            f"{cmd} & "
            f"disown"
        )
        logger.debug("Launching with: %r", [shell, "-i", "-c", payload])

        try:
            subprocess.Popen(
                [shell, "-i", "-c", payload],
                cwd=home,
                preexec_fn=os.setpgrp,
            )
            logger.debug("Launched background job: %r", cmd)
        except Exception:
            logger.exception("Failed to launch command")

        return HideWindowAction()


if __name__ == "__main__":
    TerminalRunner().run()
