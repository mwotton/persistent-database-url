{-# LANGUAGE OverloadedStrings #-}
module Database.Persist.URLSpec (main, spec) where

import Test.Hspec
import Database.Persist.URL
import Data.ByteString (ByteString)
import Data.Text (Text)

import Database.Persist.Postgresql (PostgresConf(..))

main :: IO ()
main = hspec spec

spec :: Spec
spec =
  describe "fromDatabaseUrl" $ do
    it "should parse a PostgresConf out of a ByteString" $ do
        let url = "postgres://user:password@host:1234/db" :: ByteString
        let conf = fromDatabaseUrl 10 url

        pgConnStr <$> conf `shouldBe`
            Just "user=user password=password host=host port=1234 dbname=db"
        pgPoolSize <$> conf `shouldBe` Just 10
    it "should parse a PostgresConf out of a Text" $ do
        let url = "postgres://user:password@host:1234/db" :: Text
        let conf = fromDatabaseUrl 10 url

        pgConnStr <$> conf `shouldBe`
            Just "user=user password=password host=host port=1234 dbname=db"
        pgPoolSize <$> conf `shouldBe` Just 10
    it "should handle an invalid URL" $ do
        let url = "postgres://user:password@/db" :: ByteString
        let conf = fromDatabaseUrl 10 url
        pgConnStr <$> conf `shouldBe` Nothing
    it "should handle a missing authority" $
        pgConnStr <$> fromDatabaseUrl 10 ("postgres:/db" :: ByteString)
            `shouldBe` Nothing
    it "should handle a missing path" $ do
        let url = "postgres://user:pass@example:123" :: ByteString
        let conf = fromDatabaseUrl 10 url
        pgConnStr <$> conf `shouldBe` Nothing
    it "should handle missing authentication" $
        pgConnStr <$> fromDatabaseUrl 10 ("postgres://example/db" :: ByteString)
            `shouldBe` Nothing
    it "should handle a different protocol" $ do
        let url = "mysql://user:pass@example:123/db" :: ByteString
        let conf = fromDatabaseUrl 10 url
        pgConnStr <$> conf `shouldBe` Nothing
