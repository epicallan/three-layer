module Test.Password where

import Control.Monad.Except (MonadError)
import Lib.App.Error (AppError (..))

import Hedgehog (MonadGen, Property, assert, forAll, property, withTests)
import Test.Tasty (TestTree)
import Test.Tasty.Hedgehog (testProperty)

import Lib.Util.Password (PasswordPlainText (..), mkPasswordHashWithPolicy, verifyPassword)

import qualified Crypto.BCrypt as BC
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range

test_pwdHashVerified :: [TestTree]
test_pwdHashVerified = pure $ testProperty "Password verification" pwdProperty

pwdProperty :: Property
pwdProperty = property $ do
  randomPwd <- forAll genPwd
  whenRightM (runExceptT $ mkPasswordHashWithPolicy BC.fastBcryptHashingPolicy randomPwd) $ \pwdHash ->
    assert $ verifyPassword randomPwd pwdHash


genPwd :: MonadGen m => m PasswordPlainText
genPwd = PwdPlainText <$> Gen.text (Range.constant 8 40) Gen.alphaNum