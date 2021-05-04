from pandas_datareader import data as pdr
import yfinance as yf

#Read in a list of all stock ticker symbols
symbol_list = pd.read_csv("stock_tickers.csv")
symbol_list.columns = ['ticker_symbol']

yf.pdr_override()

#Call the Yahoo Finance API for the relevant stock data, convert to tidy dataframe
df = pdr.get_data_yahoo(symbol_list['ticker_symbol'].tolist(), start = "2021-04-23", end = "2021-04-30").unstack()
#Rename the columns
df.columns = ["metric","ticker","date","value"]
#Save as a .csv file
df.to_csv("all_stocks.csv")
