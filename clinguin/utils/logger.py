"""
Module that takes care of the custom logging config, so it contains the Logger-class.
"""

import logging
import os

class Logger:
    """
    Provides methods to set the logging config appropriatly. In principle two loggers exists - one for the client (default name: clinguin_client) and one for the server (default name: clinguin_server).
    """

    class ColoredFormatter(logging.Formatter):
        """
        For colored logs.
        """

        def __init__(self, msg, use_color = True):
            logging.Formatter.__init__(self, msg)
            self.use_color = use_color

        def format(self, record):
            levelname = record.levelname
            if self.use_color and levelname in Logger.COLORS:
                color =  Logger.COLOR_SEQ % (30 + Logger.COLORS[levelname])
                levelname_color = color + levelname[0:4] + Logger.RESET_SEQ
                record.levelname = levelname_color
            return logging.Formatter.format(self, record)



    client_logger_name = "clinguin_client"
    server_logger_name = "clinguin_server"

    log_levels = {
        "NOTSET": logging.NOTSET,
        "DEBUG": logging.DEBUG,
        "INFO": logging.INFO,
        "WARNING": logging.WARNING,
        "ERROR": logging.ERROR,
        "CRITICAL": logging.CRITICAL
    }

    BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE = range(8)
    RESET_SEQ = "\033[0m"
    COLOR_SEQ = "\033[1;%dm"
    BOLD_SEQ = "\033[1m"

    @classmethod
    def formatter_message(cls, message, use_color = True):
        if use_color:
            message = message.replace("$RESET", cls.RESET_SEQ).replace("$BOLD", cls.BOLD_SEQ)
        else:
            message = message.replace("$RESET", "").replace("$BOLD", "")
        return message

    COLORS = {
        'WARNING': YELLOW,
        'INFO': GREEN,
        'DEBUG': BLUE,
        'CRITICAL': RED,
        'ERROR': RED
    }

    @classmethod
    def _get_log_file_path(cls, log_arg_dict):
        log_file_path = os.path.join("logs",
            (log_arg_dict['timestamp'] + "-" + log_arg_dict['name'] + ".log"))
        return log_file_path

    @classmethod
    def _add_shell_handler_to_logger(cls, logger, log_arg_dict):
        shell_formatter = Logger.ColoredFormatter(log_arg_dict['format_shell'])

        logger.setLevel(cls.log_levels[log_arg_dict['level']])

        handler_sh = logging.StreamHandler()
        handler_sh.setFormatter(shell_formatter)

        logger.addHandler(handler_sh)

    @classmethod
    def _add_file_handler_to_logger(cls, logger, log_arg_dict, log_file_path):
        file_formatter = Logger.ColoredFormatter(log_arg_dict['format_file'])

        with open(log_file_path, "a+") as file_object:
            file_object.write(
                "<<<<<NEW-LOG-INSTANCE-" +
                log_arg_dict['name'] +
                ">>>>>\n\n")

        handler_f = logging.FileHandler(log_file_path)
        handler_f.setFormatter(file_formatter)
        logger.addHandler(handler_f)

    @classmethod
    def setup_logger(cls, log_arg_dict, process = None):
        if process and process == "client": 
            cls.client_logger_name = log_arg_dict['name']
        elif process and process == "server":
            cls.server_logger_name = log_arg_dict['name']

        log_file_path = cls._get_log_file_path(log_arg_dict)

        logger = logging.getLogger(log_arg_dict['name'])
        if not log_arg_dict['shell_disabled']:
            cls._add_shell_handler_to_logger(logger, log_arg_dict)
        if log_arg_dict['file_enabled']:
            cls._add_file_handler_to_logger(logger, log_arg_dict, log_file_path)

    @classmethod
    def setup_uvicorn_logger_on_startup(cls, log_arg_dict):
        # ----------------------------------------------------------
        # Remove handlers from uvicorn loggers
        logger = logging.getLogger("uvicorn.access")
        for handler in logger.handlers:
            logger.removeHandler(handler)

        logger = logging.getLogger("uvicorn.error")
        for handler in logger.handlers:
            logger.removeHandler(handler)

        logger = logging.getLogger("uvicorn")
        for handler in logger.handlers:
            logger.removeHandler(handler)

        # Add new handlers to top-level-uvicorn logger
        log_file_path = cls._get_log_file_path(log_arg_dict)

        logger = logging.getLogger("uvicorn")
        if not log_arg_dict['shell_disabled']:
            cls._add_shell_handler_to_logger(logger, log_arg_dict)
        if log_arg_dict['file_enabled']:
            cls._add_file_handler_to_logger(logger, log_arg_dict, log_file_path)


