use std::str::FromStr;

use bigdecimal::BigDecimal;

use crate::{InputValueError, InputValueResult, Scalar, ScalarType, Value};

#[Scalar(internal, name = "BigDecimal")]
impl ScalarType for BigDecimal {
    fn parse(value: Value) -> InputValueResult<Self> {
        println!("[BigDecimal] value={value:?}");

        match &value {
            Value::Number(n) => {
                // println!("[BigDecimal] value is a number");

                // if let Some(f) = n.as_f64() {
                //     let val = BigDecimal::try_from(f).map_err(InputValueError::custom)?;
                //     println!("[BigDecimal] value is a f64: {f} => {val:?}");
                //     return Ok(val);
                // }

                // if let Some(f) = n.as_i64() {
                //     let val = BigDecimal::from(f);
                //     println!("[BigDecimal] value is a i64: {f} => {val:?}");
                //     return Ok(val);
                // }

                // let n2 = n.as_u64().unwrap();
                // let val = BigDecimal::from(n2);

                // println!("[BigDecimal] value is 'probably' a u64: {n2} => {val:?}");

                let val = BigDecimal::from_str(n.as_str())?;
                println!(
                    "[BigDecimal] value is a arbitrary-precision-num '{}' => {:?}",
                    n.as_str(),
                    val
                );

                // unwrap safe here, because we have check the other possibility
                Ok(val)
            }
            Value::String(s) => {
                let val = BigDecimal::from_str(s)?;
                println!("[BigDecimal] value is a string '{s}' => {:?}", val);
                Ok(val)
            },
            _ => Err(InputValueError::expected_type(value)),
        }
    }

    fn to_value(&self) -> Value {
        Value::String(self.to_string())
    }
}
